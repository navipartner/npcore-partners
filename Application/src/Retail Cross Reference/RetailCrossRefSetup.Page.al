page 6151181 "NPR Retail Cross Ref. Setup"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Retail Cross Reference Setup';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR Retail Cross Ref. Setup";
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
                    field("Pattern Guide"; "Pattern Guide")
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
                field("Table ID"; "Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table ID field';
                }
                field("Reference No. Pattern"; "Reference No. Pattern")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Reference No. Pattern field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        RetailCrossRefMgt: Codeunit "NPR Retail Cross Ref. Mgt.";
    begin
        RetailCrossRefMgt.DiscoverRetailCrossReferenceSetup(Rec);
    end;
}

