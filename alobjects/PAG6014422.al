page 6014422 "Pacsoft Customs Item Rows"
{
    // PS1.00/LS/20141021  CASE  188056 : PacSoft Module Integration Creation of Page

    Caption = 'Pacsoft Customs Item Rows';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Pacsoft Customs Item Rows";
    SourceTableView = SORTING("Shipment Document Entry No.","Entry No.");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field("Item Code";"Item Code")
                {
                }
                field("Line Information";"Line Information")
                {
                }
                field(Copies;Copies)
                {
                }
                field("Customs Value";"Customs Value")
                {
                }
                field(Content;Content)
                {
                }
                field("Country of Origin";"Country of Origin")
                {
                }
            }
        }
    }

    actions
    {
    }
}

