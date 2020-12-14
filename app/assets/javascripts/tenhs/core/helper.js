(function () {
  function formatMoney(n, c, d, t) {
    var c = isNaN((c = Math.abs(c))) ? 2 : c,
      d = d == undefined ? "." : d,
      t = t == undefined ? "," : t,
      s = n < 0 ? "-" : "",
      i = String(parseInt((n = Math.abs(Number(n) || 0).toFixed(c)))),
      j = (j = i.length) > 3 ? j % 3 : 0;

    return (
      s +
      (j ? i.substr(0, j) + t : "") +
      i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) +
      (c
        ? d +
          Math.abs(n - i)
            .toFixed(c)
            .slice(2)
        : "")
    );
  }

  var countdownTimer = 120;
  window.helper = {
    isWechat: function () {
      var ua = window.navigator.userAgent.toLowerCase();
      if (ua.match(/MicroMessenger/i) == "micromessenger") {
        return true;
      } else {
        return false;
      }
    },
    csrfToken: function () {
      return $('meta[name="csrf-token"]').attr("content");
    },
    numberToCurrency: function (n) {
      return "￥ " + formatMoney(Number(n));
    },
    startProgress: function () {
      $(".upload-progress").show();
    },
    endProgress: function () {
      $(".upload-progress").fadeOut(100);
    },
    displayDate: function (date) {
      return date.getFullYear() + "-" + (date.getMonth() + 1) + "-" + date.getDate();
    },
    ajaxModal: function (url, params) {
      $("#ajaxModalContent").html($("#ajaxModalLoadingTemplate").html());
      $("#ajaxModal").modal("show");
      params = params || {};
      $.get(url, params, function (data) {
        $("#ajaxModalContent").html(data);
      });
    },
    notice: function (msg) {
      $("#sysNotice").html('<div class="alert alert-info" role="alert"><i class="fa fa-check-circle"></i> ' + msg + "</div>");
      $("#sysNotice").show().delay(5000).fadeOut();
    },
    countdown: function ($btn) {
      if (countdownTimer <= 0) {
        countdownTimer = 120;
        $btn.html("获取验证码").removeAttr("disabled");
        return;
      }
      $btn.html("已发送（" + countdownTimer + "）").prop("disabled", true);
      setTimeout(function () {
        helper.countdown($btn);
      }, 1000);
      countdownTimer--;
    },
  };
})();
