pageextension 6014402 "NPR Config. Template Header" extends "Config. Template Header"
{
    layout
    {
        addafter(ConfigTemplateSubform)
        {
            part(NPRConfigTemplateSubform; "Config. Template Subform")
            {
                ApplicationArea = NPRRetail;
                Visible = false;
                Enabled = false;
            }
            part("NPR Aux Conf. Template Subform"; "NPR Aux Conf. Template Subform")
            {
                ApplicationArea = NPRRetail;
                Visible = false;
                Enabled = false;
            }
        }
    }
}