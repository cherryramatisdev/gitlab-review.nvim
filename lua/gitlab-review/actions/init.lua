local comment = require("gitlab-review.actions.comment")
local multiline_comment = require("gitlab-review.actions.multiline_comment")
local suggestion = require("gitlab-review.actions.suggestion")
local multiline_suggestion = require("gitlab-review.actions.multiline_suggestion")
local submit = require("gitlab-review.actions.submit")
local list_discussions = require("gitlab-review.actions.list_discussions")

return {
  comment = comment.run,
  multiline_comment = multiline_comment.run,
  suggestion = suggestion.run,
  multiline_suggestion = multiline_suggestion.run,
  open_comment_window = submit.open_comment_window,
  list_discussions = list_discussions.run,
}
