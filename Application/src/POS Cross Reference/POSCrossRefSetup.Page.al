page 6059810 "NPR POS Cross Ref. Setup"
{
    Caption = 'POS Cross Reference Setup';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR POS Cross Ref. Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            grid(Control6014406)
            {
                ShowCaption = false;
                group(Control6014404)
                {
                    ShowCaption = false;
                    field(Control6014407; '')
                    {
                        ApplicationArea = All;
                        Caption = 'Pattern Guide:                                                                                                                                                                                                                                                                                ';
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Pattern Guide:                                                                                                                                                                                                                                                                                 field';
                    }
                    field("Pattern Guide"; Rec."Pattern Guide")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        MultiLine = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Pattern Guide field';
                    }
                }
            }
            repeater(Group)
            {
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Reference No. Pattern"; Rec."Reference No. Pattern")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Reference No. Pattern field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.OnDiscoverSetup(Rec);
    end;
}

