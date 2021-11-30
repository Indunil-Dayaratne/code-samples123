using System.Web.Mvc;
using static BEAS.Web.FilterConfig;

namespace BEAS.Web.Controllers
{
    public class RolesController : Controller
    { 
        [AllowCrossSiteJson]
        public ActionResult Index()
        {
            return PartialView();
        }

        [AllowCrossSiteJson]
        public ActionResult RoleInfo()
        {
            return PartialView();
        }

    }
}