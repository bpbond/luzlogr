# Testing onAttach, onLoad code

context("luzlogr")

test_that("onLoad sets options correctly", {

  options(luzlogr.close_on_error = TRUE)
  expect_silent(.onLoad())
  expect_true(getOption("luzlogr.close_on_error"))

  options(luzlogr.close_on_error = NULL)
  expect_silent(.onLoad())
  expect_false(getOption("luzlogr.close_on_error"))
})

test_that("onAttach sets error handler correctly", {

  options(luzlogr.close_on_error = FALSE)
  expect_silent(.onAttach())

  options(luzlogr.close_on_error = TRUE)
  oe <- getOption("error")
  options(error = NULL)
  expect_silent(.onAttach())
  expect_is(getOption("error"), "call")
})
