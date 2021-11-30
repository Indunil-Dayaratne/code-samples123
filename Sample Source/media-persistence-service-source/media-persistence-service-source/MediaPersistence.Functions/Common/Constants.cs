using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Text;

namespace MediaPersistence.Functions.Common
{
    [ExcludeFromCodeCoverage]
    public static class Constants
    {
        private const string imageMimeTypeGif = "image/gif";
        private const string imageMimeTypeJpeg = "image/jpeg";
        private const string imageMimeTypePjpeg = "image/pjpeg";
        private const string imageMimeTypeXpng = "image/x-png";
        private const string imageMimeTypePng = "image/png";
        private const string imageMimeTypeSvg = "image/svg+xml";

        private const string imageFileExtensionGif = ".gif";
        private const string imageFileExtensionJpeg = ".jpeg";
        private const string imageFileExtensionJpg = ".jpg";
        private const string imageFileExtensionPng = ".png";
        private const string imageFileExtensionSvg = ".svg";

        public static string IMAGE_MIME_TYPE_GIF => imageMimeTypeGif;
        public static string IMAGE_MIME_TYPE_JPEG => imageMimeTypeJpeg;
        public static string IMAGE_MIME_TYPE_PJPEG => imageMimeTypePjpeg;
        public static string IMAGE_MIME_TYPE_XPNG => imageMimeTypeXpng;
        public static string IMAGE_MIME_TYPE_PNG => imageMimeTypePng;
        public static string IMAGE_MIME_TYPE_SVG => imageMimeTypeSvg;

        public static string IMAGE_FILENAME_EXTENSION_GIF => imageFileExtensionGif;
        public static string IMAGE_FILENAME_EXTENSION_JPEG => imageFileExtensionJpeg;
        public static string IMAGE_FILENAME_EXTENSION_JPG => imageFileExtensionJpg;
        public static string IMAGE_FILENAME_EXTENSION_PNG => imageFileExtensionPng;
        public static string IMAGE_FILENAME_EXTENSION_SVG => imageFileExtensionSvg;

        private static string imageContainerName = "images";

        public static IEnumerable<string> ValidMimeTypes
        {
            get
            {
                return new List<string> { imageMimeTypeGif, imageMimeTypeJpeg, imageMimeTypePjpeg, imageMimeTypeXpng, imageMimeTypePng, imageMimeTypeSvg };
            }
        }

        public static IEnumerable<string> ValidFilenameExtensions
        {
            get
            {
                return new List<string> { imageFileExtensionGif, imageFileExtensionJpeg, imageFileExtensionJpg, imageFileExtensionPng, imageFileExtensionSvg };
            }
        }

        public static string ImageContainerName { get => imageContainerName; }
    }
}
