page 6150694 "NPRE Service Flow Profiles"
{
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

    Caption = 'Rest. Service Flow Profiles';
    CardPageID = "NPRE Service Flow Profile Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPRE Service Flow Profile";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014405;Notes)
            {
                Visible = false;
            }
            systempart(Control6014406;Links)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

