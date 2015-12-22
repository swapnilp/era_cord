// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require bootstrap
//= require turbolinks
//= require mousescroll.js
//= require smoothscroll.js
//= require jquery.prettyPhoto.js
//= require jquery.isotope.min.js
//= require jquery.inview.min.js
//= require wow.min.js
// require_tree .


jQuery(function ($) {
  'use strict';

  $(window).scroll(function (event) {
    Scroll();
  });

  $('.navbar-collapse ul li a').on('click', function () {
    $('html, body').animate({
      scrollTop: $(this.hash).offset().top - 5
    }, 1000);
    return false;
  });

  $('.slientLink').on('click', function () {
    $('html, body').animate({
      scrollTop: $(this.hash).offset().top - 5
    }, 1000);
    return false;
  });

  function Scroll() {
    var contentTop = [];
    var contentBottom = [];
    var winTop = $(window).scrollTop();
    var rangeTop = 200;
    var rangeBottom = 500;
    $('.navbar-collapse').find('.scroll a').each(function () {
      //contentTop.push($($(this).attr('href')).offset().top);
      //contentBottom.push($($(this).attr('href')).offset().top + $($(this).attr('href')).height());
    })
    $.each(contentTop, function (i) {
      if (winTop > contentTop[i] - rangeTop) {
        $('.navbar-collapse li.scroll')
          .removeClass('active')
          .eq(i).addClass('active');
      }
    })
  };

  $('#tohash').on('click', function () {
    $('html, body').animate({
      scrollTop: $(this.hash).offset().top - 5
    }, 1000);
    return false;
  });


  new WOW().init();

  smoothScroll.init();


  $(window).load(function () {
    'use strict';
    var $portfolio_selectors = $('.portfolio-filter >li>a');
    var $portfolio = $('.portfolio-items');
    $portfolio.isotope({
      itemSelector: '.portfolio-item',
      layoutMode: 'fitRows'
    });

    $portfolio_selectors.on('click', function () {
      $portfolio_selectors.removeClass('active');
      $(this).addClass('active');
      var selector = $(this).attr('data-filter');
      $portfolio.isotope({
        filter: selector
      });
      return false;
    });
  });

  $(document).ready(function () {

    $.fn.animateNumbers = function (stop, commas, duration, ease) {
      return this.each(function () {
        var $this = $(this);
        var start = parseInt($this.text().replace(/,/g, ""));
        commas = (commas === undefined) ? true : commas;
        $({
          value: start
        }).animate({
          value: stop
        }, {
          duration: duration == undefined ? 1000 : duration,
          easing: ease == undefined ? "swing" : ease,
          step: function () {
            $this.text(Math.floor(this.value));
            if (commas) {
              $this.text($this.text().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,"));
            }
          },
          complete: function () {
            if (parseInt($this.text()) !== stop) {
              $this.text(stop);
              if (commas) {
                $this.text($this.text().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,"));
              }
            }
          }
        });
      });
    };

    $('.business-stats').bind('inview', function (event, visible, visiblePartX, visiblePartY) {
      var $this = $(this);
      if (visible) {
        $this.animateNumbers($this.data('digit'), false, $this.data('duration'));
        $this.unbind('inview');
      }
    });
  });


  $("a[rel^='prettyPhoto']").prettyPhoto({
    social_tools: false
  });
});
