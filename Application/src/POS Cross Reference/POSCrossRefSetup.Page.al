page 6059810 "NPR POS Cross Ref. Setup"
{
    Caption = 'POS Cross Reference Setup';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR POS Cross Ref. Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


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

                        Caption = 'Pattern Guide:                                                                                                                                                                                                                                                                                ';
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Pattern Guide:                                                                                                                                                                                                                                                                                 field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Pattern Guide"; Rec."Pattern Guide")
                    {

                        Editable = false;
                        MultiLine = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Pattern Guide field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            repeater(Group)
            {
                field("Table Name"; Rec."Table Name")
                {

                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Reference No. Pattern"; Rec."Reference No. Pattern")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Reference No. Pattern field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.OnDiscoverSetup(Rec);
    end;
}

