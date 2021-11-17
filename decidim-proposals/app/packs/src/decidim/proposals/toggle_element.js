$(() => {

  const $expandButton = $("[data-toggle='show']")
  const $hideButton = $("[data-toggle='hide']")
  const $toggleElements = $(".toggle-visibility")

  $expandButton.on("click", (e) => {
    e.preventDefault()
    $toggleElements.removeClass("toggle-visibility")

    $(e.target).addClass("toggle-visibility")
  })

  $hideButton.on("click", (e) => {
    e.preventDefault()
    $toggleElements.addClass("toggle-visibility")

    $(e.target).addClass("toggle-visibility")
  })
  // const $hideButton = $("[data-toggle-class]")
  // const toggleClass = $expandButton.data("toggle-class")
  //
  // console.log($expandButton)
  // console.log(toggleClass)
  //
  // $elementsToToggle = $("." + toggleClass)
  //
  // $expandButton.on("click", () => {
  //   console.log($(toggleClass))
  //   $elementsToToggle.addClass("toggle--expanded")
  //   $elementsToToggle.removeClass(toggleClass)
  // })
});
