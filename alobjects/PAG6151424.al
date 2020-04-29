page 6151424 "Magento Item Group Links"
{
    // MAG1.17/TS/20150526 CASE 210909  Page Created
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Magento Item Group Links';
    PageType = ListPart;
    SourceTable = "Magento Item Group Link";
    SourceTableTemporary = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No.";"Item No.")
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

    trigger OnAfterGetRecord()
    var
        WebLinkToItemGroup: Record "Magento Item Group Link";
    begin
    end;
}

