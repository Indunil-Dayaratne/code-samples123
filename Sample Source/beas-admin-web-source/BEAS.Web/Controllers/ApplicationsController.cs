using System.Web.Mvc;
using static BEAS.Web.FilterConfig;

namespace BEAS.Web.Controllers
{
    public class ApplicationsController : Controller
    { 
        [AllowCrossSiteJson]
        public ActionResult Index()
        {
            return PartialView();
        }

        [AllowCrossSiteJson]
        public ActionResult ApplicationInfo()
        {
            return PartialView("ApplicationInfo");
        }

        [AllowCrossSiteJson]
        public ActionResult ApplicationAreaInfo()
        {
            return PartialView("ApplicationAreaInfo");
        }

    }
}