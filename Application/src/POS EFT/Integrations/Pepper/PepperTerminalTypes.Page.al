page 6184495 "NPR Pepper Terminal Types"
{
    Extensible = False;
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Terminal Types';
    CardPageID = "NPR Pepper Terminal Type Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Pepper Terminal Type";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ID; Rec.ID)
                {

                    ToolTip = 'Specifies the value of the ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Active; Rec.Active)
                {

                    ToolTip = 'Specifies the value of the Active field';
                    ApplicationArea = NPRRetail;
                }
                field(Deprecated; Rec.Deprecated)
                {

                    ToolTip = 'Specifies the value of the Deprecated field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

