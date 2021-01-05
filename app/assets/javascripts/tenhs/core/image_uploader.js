(function () {
  window.image = (function () {
    var self = {};

    /*
     * 点击打开图片上传
     * @param fileId <input type="file" id="fileId">
     */
    self.open = function (fileId) {
      $(fileId).click();
    };

    /*
     * 上传图片（适用canvas压缩后上传）<input type="file" id="fileId" onchange="image.upload(...)">
     * @param imgId 用于preview的<img id="imgId">
     * @param srcId 用于上传图片url的<input type="hidden" id="srcId">
     * @param url   后端地址
     * @param width 图片宽度
     * @param height 图片高度
     */
    self.upload = function (imgId, srcId, url, width, height, callback) {
      url = url || "/admin/images";
      var file = window.event.target.files[0];
      compress(file, width, height, function (img) {
        save(img, file.name, imgId, srcId, url, callback);
      });
    };

    /*
     * 上传图片（提供图片编辑框）<input type="file" id="fileId" onchange="image.cropAndUpload(...)">
     * 需要<%=render "_cropper" %>
     * @param imgId 用于preview的<img id="imgId">
     * @param srcId 用于上传图片url的<input type="hidden" id="srcId">
     * @param url   后端地址
     * @param width 图片宽度
     * @param height 图片高度
     * @param radio 图片radio
     */
    var cropper, targetImgId, targetSrcId, fileName, cropWidth, cropHeight, uploadUrl;
    self.cropAndUpload = function (imgId, srcId, url, width, height, radio) {
      var file = window.event.target.files[0];
      targetImgId = imgId;
      targetSrcId = srcId;
      fileName = file.name;
      cropWidth = width;
      cropHeight = height;
      uploadUrl = url;
      radio = radio || 1;

      var reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = function () {
        var image = document.getElementById("_cropper_img");
        image.src = reader.result;
        if (cropper) {
          cropper.destroy();
        }
        cropper = new Cropper(image, {
          aspectRatio: radio,
          maxContainerWidth: 600,
          dragMode: "move",
        });
        $("#cropperModal").modal("show");
      };
    };

    self.uploadAfterCrop = function () {
      var canvas = cropper.getCroppedCanvas({ width: cropWidth, height: cropHeight }).toBlob(function (blob) {
        save(blob, fileName, targetImgId, targetSrcId, uploadUrl, null);
        $("#cropperModal").modal("hide");
      });
    };

    var save = function (img, name, imgId, srcId, url, callback) {
      var data = new FormData();
      data.append("file", img, name);
      helper.startProgress();
      $.ajax({
        url: url,
        type: "POST",
        data: data,
        cache: false,
        dataType: "json",
        processData: false,
        contentType: false,
        success: function (data, textStatus, jqXHR) {
          $(imgId).val(data.filelink);
          $(srcId).attr("src", data.filelink);
	  if (callback) {
	    callback(data.filelink);
	  }
          helper.endProgress();
        },
      });
    };

    var compress = function (file, width, height, callback) {
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
        var maxWidth = width,
          maxHeight = height;
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

    return self;
  })();
})();
