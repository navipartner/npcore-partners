page 6151181 "Retail Cross Reference Setup"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Retail Cross Reference Setup';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Retail Cross Reference Setup";
    UsageCategory = Administration;

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
                    field(Control6014407;'')
                    {
                        Caption = 'Pattern Guide:                                                                                                                                                                                                                                                                                ';
                        HideValue = true;
                        ShowCaption = false;
                    }
                    field("Pattern Guide";"Pattern Guide")
                    {
                        Editable = false;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                }
            }
            repeater(Group)
            {
                field("Table ID";"Table ID")
                {
                }
                field("Reference No. Pattern";"Reference No. Pattern")
                {
                    ShowMandatory = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        RetailCrossRefMgt: Codeunit "Retail Cross Ref. Mgt.";
    begin
        RetailCrossRefMgt.DiscoverRetailCrossReferenceSetup(Rec);
    end;
}

