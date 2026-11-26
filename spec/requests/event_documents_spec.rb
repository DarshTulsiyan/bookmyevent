require "rails_helper"
require "tempfile"

RSpec.describe "Event authorization documents", type: :request do
  let(:event) { FactoryBot.create(:event, status: :draft) }
  let(:pdf) { "%PDF-1.4\nExample permit\n%%EOF\n" }

  def log_in(user)
    post login_path, params: { email: user.email, password: "Password123!" }
  end

  def submit_document(contents)
    Tempfile.create([ "permit", ".pdf" ]) do |file|
      file.binmode
      file.write(contents)
      file.flush
      upload = Rack::Test::UploadedFile.new(file.path, "application/pdf")
      patch submit_for_review_event_path(event), params: { authorization_document: upload }
    end
  end

  it "accepts a PDF from the owner and keeps the pending event off the public listing" do
    log_in(event.organizer)
    submit_document(pdf)

    expect(response).to redirect_to(edit_event_path(event))
    expect(event.reload).to be_pending
    expect(event.authorization_document.download).to eq(pdf)
    expect(Event.publicly_visible).not_to include(event)
  end

  it "requires a document" do
    log_in(event.organizer)
    patch submit_for_review_event_path(event)

    expect(flash[:alert]).to include("Upload a PDF, JPG, or PNG")
    expect(event.reload).to be_draft
    expect(event.authorization_document).not_to be_attached
  end

  it "rejects unsupported contents even when the upload claims to be a PDF" do
    log_in(event.organizer)
    submit_document("This is a plain text file.")

    expect(flash[:alert]).to include("Upload a PDF, JPG, or PNG")
    expect(event.reload).to be_draft
    expect(event.authorization_document).not_to be_attached
  end

  it "rejects a PDF larger than 10 MB" do
    log_in(event.organizer)
    submit_document(pdf.ljust(10.megabytes + 1))

    expect(flash[:alert]).to include("up to 10 MB")
    expect(event.reload).to be_draft
    expect(event.authorization_document).not_to be_attached
  end

  it "prevents another organizer from submitting an event" do
    log_in(FactoryBot.create(:user, role: :organizer))
    submit_document(pdf)

    expect(response).to have_http_status(:not_found)
    expect(event.reload).to be_draft
  end

  it "replaces rejected proof and clears the previous rejection reason" do
    event.update!(status: :rejected, rejection_reason: "Wrong date")
    event.authorization_document.attach(io: StringIO.new(pdf), filename: "old.pdf")
    replacement = pdf.sub("Example permit", "Replacement permit")

    log_in(event.organizer)
    submit_document(replacement)

    expect(event.reload).to be_pending
    expect(event.rejection_reason).to be_nil
    expect(event.authorization_document.download).to eq(replacement)
  end


  it "logs storage errors without leaking credentials and cleans up the blob" do
    log_in(event.organizer)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("B2_KEY_ID").and_return("secret-key-id")
    allow(ENV).to receive(:[]).with("B2_APPLICATION_KEY").and_return(nil)
    allow_any_instance_of(ActiveStorage::Blob).to receive(:upload_without_unfurling)
      .and_raise(StandardError, "Rejected secret-key-id")
    expect(Rails.logger).to receive(:error).with(
      a_string_including("Authorization document upload failed", "[FILTERED]")
    )
    expect { submit_document(pdf) }.not_to change(ActiveStorage::Blob, :count)
    expect(flash[:alert]).to include("could not be uploaded")
    expect(event.reload).to be_draft
  end

  it "reports a save validation failure and cleans up the uploaded blob" do
    log_in(event.organizer)
    allow_any_instance_of(Event).to receive(:submit_for_review) do |record, _blob|
      record.errors.add(:base, "Review could not be saved")
      false
    end
    expect { submit_document(pdf) }.not_to change(ActiveStorage::Blob, :count)
    expect(flash[:alert]).to include("Review could not be saved")
    expect(event.reload).to be_draft
  end

  describe "downloading proof after publication" do
    before do
      event.update!(status: :approved)
      event.authorization_document.attach(io: StringIO.new(pdf), filename: "permit.pdf")
    end

    it "allows the owner and admin to download it as a private attachment" do
      [ event.organizer, FactoryBot.create(:user, role: :admin) ].each do |user|
        log_in(user)
        get authorization_document_event_path(event)

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(pdf)
        expect(response.headers["Content-Disposition"]).to include("attachment", "permit.pdf")
        expect(response.headers["Cache-Control"]).to include("no-store")
      end
    end

    it "lets an admin view a verified PDF inline with ?view=1" do
      event.authorization_document.blob.update!(content_type: "application/pdf")
      log_in(FactoryBot.create(:user, role: :admin))
      get authorization_document_event_path(event, view: 1)

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(pdf)
      expect(response.media_type).to eq("application/pdf")
      expect(response.headers["Content-Disposition"]).to include("inline", "permit.pdf")
      expect(response.headers["X-Content-Type-Options"]).to eq("nosniff")
      expect(response.headers["Cache-Control"]).to include("no-store")
    end

    it "still forces a download for ?view=1 when the type is not viewable" do
      event.authorization_document.blob.update!(content_type: "text/html")
      log_in(event.organizer)
      get authorization_document_event_path(event, view: 1)

      expect(response.media_type).to eq("application/octet-stream")
      expect(response.headers["Content-Disposition"]).to include("attachment")
    end

    it "denies anonymous visitors and unrelated accounts even though the event is public" do
      get event_path(event)
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("Download authorization document")

      get authorization_document_event_path(event)
      expect(response).to have_http_status(:not_found)

      %i[attendee organizer].each do |role|
        log_in(FactoryBot.create(:user, role: role))
        get authorization_document_event_path(event)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
