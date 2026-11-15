# BookMyEvent Product Backlog

This backlog is built from [user_stories.md](user_stories.md) and the team's [GitHub issues](https://github.com/DarshTulsiyan/bookmyevent/issues).
Points come from the GitHub issues and the updated user stories.

**Status key:** ✅ Done · 🟡 In Progress (partly built) · ⬜ To Do · ⭐ Stretch goal

## Team

| Member | GitHub | Sprint 1 issues | Sprint 1 points |
|---|---|---|---|
| Darsh Tulsiyan | [@DarshTulsiyan](https://github.com/DarshTulsiyan) | #22, #17 | 5 |
| Tanvi Patel | [@Tanu1007](https://github.com/Tanu1007) | #20, #21 | 5 |
| Ankita Dan | [@ankitadan](https://github.com/ankitadan) | #26 | 5 |
| Yash Jugade | [@yashjugade-tamu](https://github.com/yashjugade-tamu) | #24, #23 | 5 |
| Varsha Goalla | [@varshagoalla](https://github.com/varshagoalla) | #25 | 5 |
| Bhagavatiraj Yadav | [@Bhagavatiraj](https://github.com/Bhagavatiraj) | #18, #19 | 5 |
| **Total** | | **10 issues** | **30** |

## Sprint 1 (Done, 30 points)

All 10 Sprint 1 issues are closed.

| Issue | Title | User Story | Owner | Points | Status |
|---|---|---|---|---|---|
| [#22](https://github.com/DarshTulsiyan/bookmyevent/issues/22) | Project Initialisation | Setup | Darsh Tulsiyan | — | ✅ Done |
| [#17](https://github.com/DarshTulsiyan/bookmyevent/issues/17) | User Sign Up, Log In, and Log Out | US-01 | Darsh Tulsiyan | 5 | ✅ Done |
| [#20](https://github.com/DarshTulsiyan/bookmyevent/issues/20) | Event model creation | US-02 | Tanvi Patel | 3 | ✅ Done |
| [#21](https://github.com/DarshTulsiyan/bookmyevent/issues/21) | View and Manage Submitted Events | US-02 | Tanvi Patel | 2 | ✅ Done |
| [#26](https://github.com/DarshTulsiyan/bookmyevent/issues/26) | Organizer Defines and Manages Ticket Tiers with Capacity | US-03 | Ankita Dan | 5 | ✅ Done |
| [#24](https://github.com/DarshTulsiyan/bookmyevent/issues/24) | Add Public Event Browsing and Event Details Pages | US-04 | Yash Jugade | 2 | ✅ Done |
| [#23](https://github.com/DarshTulsiyan/bookmyevent/issues/23) | Build Admin Dashboard and Event Moderation Views | US-12 (part) | Yash Jugade | 3 | ✅ Done |
| [#25](https://github.com/DarshTulsiyan/bookmyevent/issues/25) | Attendee Books Tickets and Receives a Booking ID with Ticket IDs | US-05 | Varsha Goalla | 5 | ✅ Done |
| [#18](https://github.com/DarshTulsiyan/bookmyevent/issues/18) | Admin Approves or Rejects Events | US-07 | Bhagavatiraj Yadav | 3 | ✅ Done |
| [#19](https://github.com/DarshTulsiyan/bookmyevent/issues/19) | Sold-Out Message When Capacity Is Full | US-08 | Bhagavatiraj Yadav | 2 | ✅ Done |

### Sprint 1 user stories covered

| ID | Story | Points | Issues |
|---|---|---|---|
| US-01 | User sign up, log in, and log out | 5 | #17 |
| US-02 | Organizer creates an event | 5 | #20, #21 |
| US-03 | Organizer defines ticket tiers with capacity | 5 | #26 |
| US-04 | Attendee browses public events | 2 | #24 |
| US-05 | Attendee books tickets (Booking ID + Ticket IDs) | 5 | #25 |
| US-07 | Admin approves or rejects events | 3 | #18 |
| US-08 | Sold-out message when capacity is full | 2 | #19 |

Issue #23 delivered the first part of US-12 (Admin Dashboard) early: summary counts, user lists, and the pending / published / rejected event views.

---

## Sprint 2 Backlog

| Priority | ID | Story | Role | Points | Status | Owner |
|---|---|---|---|---|---|---|
| 8 | US-06 | Organizer checks in an attendee by Ticket ID | Organizer | 5 | ⬜ To Do | TBD |
| 9 | US-09 | Duplicate check-in rejection | Organizer | 2 | ⬜ To Do | TBD |
| 10 | US-10 | Unauthorized access redirect | All Users | 2 | 🟡 In Progress | TBD |
| 11 | US-11 | Organizer dashboard | Organizer | 3 | 🟡 In Progress | TBD |
| 12 | US-12 | Admin dashboard | Admin | 3 | 🟡 In Progress | TBD |
| 13 | US-13 | Waitlist for sold-out events | Attendee | 5 | ⭐ ⬜ To Do | TBD |
| 14 | US-14 | Organizer analytics per event | Organizer | 5 | ⭐ ⬜ To Do | TBD |
| 15 | US-15 | Organizer uploads venue booking proof for admin review | Organizer / Admin | 3 | ⭐ ⬜ To Do | TBD |

**Committed:** 15 points · **Stretch:** 13 points

### US-06: Organizer Checks In an Attendee by Ticket ID ⬜
*5 points.* Organizers check attendees in at the door by Ticket ID or name.
- [ ] Check-in dashboard where the organizer enters a Ticket ID.
- [ ] Verify the ticket belongs to the event, then set `checked_in_at`.
- [ ] Show a check-in confirmation message.

*Notes:* The `tickets.checked_in_at` column already exists. Still needed: routes, a controller, and a view. Only the event's organizer should be able to check people in.

### US-09: Duplicate Check-In Rejection ⬜
*2 points. Depends on US-06.*
- [ ] Reject check-in if the ticket was already used.
- [ ] Show an "already checked in" error.
- [ ] Keep the original check-in timestamp.

### US-10: Unauthorized Access Redirect 🟡
*2 points.*
- [x] Role filters (`logged_in_only`, `attendee_only`, `organizer_only`, `admin_only`) block restricted pages.
- [ ] Redirect unauthenticated or unauthorized users to login every time, with an explanatory message.
- [ ] After a successful login, return the user to the page they originally asked for. This needs a stored return-to URL.

### US-11: Organizer Dashboard 🟡
*3 points. Builds on #21.*
- [ ] Dashboard lists the organizer's events with title, date, status, capacity, and attendee count. The current page shows the organizer's events and their status, but not attendee counts.
- [ ] Links to each event's details and check-in pages. Check-in depends on US-06.
- [x] Organizers can only view and edit their own events.

### US-12: Admin Dashboard 🟡
*3 points. Builds on #23.*
- [x] Shows total users, total events, and total registrations.
- [x] Approve or reject events from the pending list.
- [ ] Manage user accounts, e.g. suspend or reactivate. The user list and `suspended` flag exist, but admins have no action to change it.
- [x] Non-admins can't access the page.

### US-13 (Stretch): Waitlist for Sold-Out Events ⬜
*5 points. Depends on booking cancellation, which no story covers yet.*
- [ ] Attendee can join a waitlist when an event is full.
- [ ] Waitlist keeps its order.
- [ ] When a spot opens, the next attendee is promoted automatically and gets a Ticket ID.

### US-14 (Stretch): Organizer Analytics per Event ⬜
*5 points. Depends on US-06.*
- [ ] Total registrations and breakdown by tier.
- [ ] Checked-in count and check-in rate (checked in ÷ registrations × 100%).
- [ ] Only the event's owner can see it.

### US-15 (Stretch): Organizer Uploads Venue Booking Proof for Admin Review ⬜
*3 points. Builds on US-02 and US-07.* Organizers upload proof that they booked the venue (a PDF or image of the booking confirmation) so the admin can verify it before approving the event.
- [ ] Organizer can attach a venue booking proof file when creating or editing an event.
- [ ] Only PDF, JPG, and PNG files are accepted. Other file types and files that are too large are rejected with an error message.
- [ ] An event cannot be approved until a proof is attached.
- [ ] Admin can view or download the proof while reviewing the pending event, then approve or reject it.
- [ ] Only the event's organizer and admins can access the proof file.

*Notes:* Use Active Storage (`has_one_attached :venue_proof` on `Event`). On Render, files need cloud storage such as S3, because the local disk is wiped on every deploy.

---

## Open Items / Notes
- **Sprint 2 owners:** Assign each story to a team member and open GitHub issues for them, as in Sprint 1.
- **Booking cancellation** has no story yet, but US-13 needs a spot to open up. Add a story before starting US-13.
- **Check-in by name:** US-06 says "Ticket ID or name", but its acceptance criteria only cover Ticket ID. Decide whether name search is in scope.
- **Story points:** The retrospective found that auth and role setup took more effort than estimated. Re-check the Sprint 2 estimates in planning.
