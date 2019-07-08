page 6151418 "Magento Item Group Link"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.21/MHA/20151118 CASE 227359 Added function SetRootNo and Root Filters
    // MAG1.22/MHA/20151202  CASE 228290 Changed SETRANGE to SETFILTER for ItemGroup."Root No." as blank should include all
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Item Group Link';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = CardPart;
    ShowFilter = false;
    SourceTable = "Magento Item Group Link";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Item Group";"Item Group")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        MagentoItemGroup: Record "Magento Item Group";
                    begin
                        //-MAG1.21
                        MagentoItemGroup.FilterGroup(2);
                        //-MAG1.22
                        //MagentoItemGroup.SETRANGE("Root No.",RootNo);
                        MagentoItemGroup.SetFilter("Root No.",RootNo);
                        //+MAG1.22
                        MagentoItemGroup.FilterGroup(0);
                        if PAGE.RunModal(PAGE::"Magento Item Group List",MagentoItemGroup) <> ACTION::LookupOK then
                          exit;

                        Validate("Item Group",MagentoItemGroup."No.");
                        //+MAG1.21
                    end;
                }
                field("Item Group Name";"Item Group Name")
                {
                }
                field(Position;Position)
                {
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
        SetFilter("Root No.",RootNo);
        FilterGroup(0);
        CurrPage.Update(false);
        //+MAG1.21
    end;
}

