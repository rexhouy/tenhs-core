(function () {
  window.wysiwyg = (function () {
    var self = {};

    var menus = ["head", "bold", "italic", "underline", "fontSize", "foreColor", "justify", "link", "image"];

    var compress = function (file, callback) {
      var reader = new FileReader(),
        img = new Image();
      // 缩放图片需要的canvas
      var canvas = document.createElement("canvas");
      var context = canvas.getContext("2d");

      // base64地址图片加载完毕后
      img.onload = function () {
        // 图片原始尺寸
        var originWidth = this.width;
        var originHeight = this.height;
        // 最大尺寸限制
        var maxWidth = 800,
          maxHeight = 1000;
        // 目标尺寸
        var targetWidth = originWidth,
          targetHeight = originHeight;
        // 图片尺寸超过1000x1000的限制
        if (originWidth > maxWidth || originHeight > maxHeight) {
          if (originWidth / originHeight > maxWidth / maxHeight) {
            // 更宽，按照宽度限定尺寸
            targetWidth = maxWidth;
            targetHeight = Math.round(maxWidth * (originHeight / originWidth));
          } else {
            targetHeight = maxHeight;
            targetWidth = Math.round(maxHeight * (originWidth / originHeight));
          }
        }

        // canvas对图片进行缩放
        canvas.width = targetWidth;
        canvas.height = targetHeight;
        // 清除画布
        context.clearRect(0, 0, targetWidth, targetHeight);
        // 图片压缩
        context.drawImage(img, 0, 0, targetWidth, targetHeight);
        // canvas转为Blob
        canvas.toBlob(function (blob) {
          callback(blob);
        }, file.type || "image/png");
      };

      // 文件base64化，以便获知图片原始尺寸
      reader.onload = function (e) {
        img.src = e.target.result;
      };
      reader.readAsDataURL(file);
    };

    var uploadImg = function (files, insert) {
      var data = new FormData();
      var file = files[0];
      compress(files[0], function (img) {
        data.append("file", img, file.name);
        helper.startProgress();
        $.ajax("/core/images", {
          type: "POST",
          data: data,
          cache: false,
          dataType: "json",
          processData: false, // Don't process the files
          contentType: false, // Set content type to false as jQuery will tell the server its a query string request
        })
          .done(function (data, textStatus, jqXHR) {
            insert(data.filelink);
          })
          .fail(function () {
            alert("上传图片失败！");
          })
          .always(function () {
            helper.endProgress();
          });
      });
    };

    self.init = function () {
      if (!$(".wysiwyg")[0]) {
        return;
      }
      var input = $("#" + $(".wysiwyg").attr("for"));
      var editor = new wangEditor(".wysiwyg");

      editor.customConfig.onchange = function (html) {
        input.val(html);
      };
      editor.customConfig.menus = menus;
      editor.customConfig.customUploadImg = uploadImg;
      editor.create();
    };

    return self;
  })();
})();
