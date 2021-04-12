page 6184495 "NPR Pepper Terminal Types"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Terminal Types';
    CardPageID = "NPR Pepper Terminal Type Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Pepper Terminal Type";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ID field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active field';
                }
                field(Deprecated; Rec.Deprecated)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deprecated field';
                }
            }
        }
    }

    actions
    {
    }
}

