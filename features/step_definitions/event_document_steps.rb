require "tmpdir"

Given("a draft event {string} exists") do |title|
  @admin_event = FactoryBot.create(:event, title: title, status: :draft)
end

When("the organizer submits the document {string}") do |filename|
  Dir.mktmpdir do |directory|
    document = File.join(directory, filename)
    File.write(document, "%PDF-1.4\nSample authorization\n%%EOF\n")
    attach_file "Authorization document", document
    click_button(@admin_event.reload.rejected? ? "Replace and resubmit" : "Submit for review")
  end
end

Then("the authorization document downloads as {string}") do |filename|
  @document_path = find_link("Download authorization document")[:href]
  click_link "Download authorization document"

  expect(page.status_code).to eq(200)
  expect(page.response_headers["Content-Disposition"]).to include(filename)
end

When("the admin rejects the event with reason {string}") do |reason|
  visit event_path(@admin_event)
  fill_in "Rejection reason", with: reason
  click_button "Reject"
end

When("the admin publishes the event") do
  click_button "Approve & publish"
end

Then("the authorization document URL returns 404") do
  visit @document_path
  expect(page.status_code).to eq(404)
end
