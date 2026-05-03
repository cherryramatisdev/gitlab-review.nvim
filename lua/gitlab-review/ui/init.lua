local popups = require("gitlab-review.ui.popups")
local loading = require("gitlab-review.ui.loading")

return {
  open_window = popups.open_window,
  set_loading_title = loading.set_loading_title,
}

