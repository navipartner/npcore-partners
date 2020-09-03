page 6151418 "NPR Magento Category Links"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.21/MHA/20151118 CASE 227359 Added function SetRootNo and Root Filters
    // MAG1.22/MHA/20151202  CASE 228290 Changed SETRANGE to SETFILTER for Category."Root No." as blank should include all
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.26/MHA /20200601  CASE 404580 Magento "Item Group" renamed to "Category"

    Caption = 'Magento Category Links';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "NPR Magento Category Link";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Category Id"; "Category Id")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        MagentoCategory: Record "NPR Magento Category";
                    begin
                        //-MAG1.21
                        MagentoCategory.FilterGroup(2);
                        //-MAG1.22
                        //MagentoCategory.SETRANGE("Root No.",RootNo);
                        MagentoCategory.SetFilter("Root No.", RootNo);
                        //+MAG1.22
                        MagentoCategory.FilterGroup(0);
                        //-MAG2.26 [404580]
                        if MagentoCategory.Get("Category Id") then;
                        //+MAG2.26 [404580]
                        if PAGE.RunModal(PAGE::"NPR Magento Category List", MagentoCategory) <> ACTION::LookupOK then
                            exit;

                        Validate("Category Id", MagentoCategory.Id);
                        //+MAG1.21
                    end;
                }
                field("Category Name"; "Category Name")
                {
                    ApplicationArea = All;
                }
                field(Position; Position)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //-MAG1.21
        "Root No." := RootNo;
        //+MAG1.21
    end;

    var
        RootNo: Code[20];

    procedure SetRootNo(NewRootNo: Code[20])
    begin
        //-MAG1.21
        RootNo := NewRootNo;
        FilterGroup(2);
        SetFilter("Root No.", RootNo);
        FilterGroup(0);
        CurrPage.Update(false);
        //+MAG1.21
    end;
}

