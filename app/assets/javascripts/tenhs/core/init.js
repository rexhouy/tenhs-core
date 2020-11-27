(function () {
  $(function () {
    $.datetimepicker.setLocale("ch");
    $(".date-picker").datetimepicker({
      timepicker: false,
      format: "Y-m-d",
    });
    $(".datetime-picker").datetimepicker({
      format: "Y-m-d H:i:00",
    });
    $(".time-picker").datetimepicker({
      format: "H:i:00",
    });
    $(".datetime-picker-end").datetimepicker({
      format: "Y-m-d H:i:59",
      allowTimes: [
        "00:59",
        "01:59",
        "02:59",
        "03:59",
        "04:59",
        "05:59",
        "06:59",
        "07:59",
        "08:59",
        "09:59",
        "10:59",
        "11:59",
        "12:59",
        "13:59",
        "14:59",
        "15:59",
        "16:59",
        "17:59",
        "18:59",
        "19:59",
        "20:59",
        "21:59",
        "22:59",
        "23:59",
      ],
    });
    $(".popover-container").popover();
    $(".tooltip-container").tooltip();
    $('[data-toggle="popover"]').popover();
    wysiwyg.init();
    $("#sysNotice").show().delay(5000).fadeOut();
  });
})();
