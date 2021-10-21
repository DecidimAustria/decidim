$(() => {
  const $overviewSidebar = $("#proposal__overview")
  let latestKnownScrollY = 0
  let sticky = false;
  let ticking = false;
  const stickyCssClass = 'proposal__overview--sticky'
  const $header = $(".header")
  const $processHeader = $("#content .process-header")
  const $processWrapper = $("#content .wrapper")
  const wrapperPaddingTop = $processWrapper.innerWidth() - $processWrapper.width()
  const headerOffset = parseFloat($header.height()) + parseFloat($processHeader.height()) + parseFloat(wrapperPaddingTop)

  function requestTick() {
    if(!ticking) {
      requestAnimationFrame(updateStickyElement);
    }

    ticking = true;
  }

  function updateStickyElement() {       
    ticking = false

    if (latestKnownScrollY > headerOffset && !sticky) {
      sticky = true;
      $overviewSidebar.addClass(stickyCssClass);
    } else if(latestKnownScrollY < headerOffset && sticky) {
      sticky=false;
      $overviewSidebar.removeClass(stickyCssClass);
    }
  }

  const onScroll = () => {
    console.log("scroll", window.pageYOffset)
    latestKnownScrollY = window.pageYOffset || window.scrollY || document.documentElement.scrollTop;
    requestTick()
  }

  $(document).on('scroll', onScroll)
});
