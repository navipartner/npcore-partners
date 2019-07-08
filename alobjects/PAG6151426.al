page 6151426 "Magento Custom Option List"
{
    // MAG1.22/TR/20160414  CASE 238563 Magento Custom Options
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Action "Card"
    // MAG2.18/BHR /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Custom Options';
    CardPageID = "Magento Custom Option Card";
    Editable = false;
    PageType = List;
    SourceTable = "Magento Custom Option";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Type;Type)
                {
                }
                field(Required;Required)
                {
                }
                field("Max Length";"Max Length")
                {
                }
                field(Position;Position)
                {
                }
                field(Price;Price)
                {
                }
                field("Price Type";"Price Type")
                {
                }
                field("Sales Type";"Sales Type")
                {
                }
                field("Sales No.";"Sales No.")
                {
                }
                field("No. Series";"No. Series")
                {
                }
                field("Item Count";"Item Count")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Card)
            {
                Caption = 'Card';
                Image = Card;
            }
        }
    }
}

