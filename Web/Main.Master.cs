﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WizardGame.Helpers;
namespace WizardGame
{
    public partial class Main : System.Web.UI.MasterPage
    {
        public bool IsValidSession = false;

        protected void Page_Load(object sender, EventArgs e)
        {
            IsValidSession = Functions.IsValidSession();
        }
    }
}