(function () {
  window.captcha = (function () {
    var self = {};

    var cancelCoolDown = false;
    var coolDown = function (time, $btn) {
      if (time === 0 || cancelCoolDown) {
        $btn.removeAttr("disabled").html("获取验证码");
        cancelCoolDown = false;
        return;
      }
      $btn.html("获取验证码(" + time + ")");
      setTimeout(function () {
        coolDown(time - 1, $btn);
      }, 1000);
    };

    self.cast = function (btn, mobile) {
      if (mobile == null || mobile.length != 11 || isNaN(mobile)) {
        alert("请输入合法的手机号");
        return;
      }
      $btn = $(btn);
      $btn.attr("disabled", "disabled");
      $.post("/core/captcha.json", {
        mobile: mobile,
        authenticity_token: helper.csrfToken(),
      }).done(function (data) {
        if (data.status != "ok") {
          cancelCoolDown = true;
        }
        coolDown(60, $btn);
      });
    };

    return self;
  })();
})();
