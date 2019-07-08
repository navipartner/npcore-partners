page 6014674 "Endpoint List"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created

    Caption = 'Endpoint List';
    CardPageID = "Endpoint Card";
    Editable = false;
    PageType = List;
    SourceTable = Endpoint;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Table No.";"Table No.")
                {
                }
                field("Table Name";"Table Name")
                {
                }
                field(Active;Active)
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Requests)
            {
                Caption = 'Requests';
                Image = XMLFile;
                RunObject = Page "Endpoint Request List";
                RunPageLink = "Endpoint Code"=FIELD(Code);
            }
            action("Request Batches")
            {
                Caption = 'Request Batches';
                Image = XMLFileGroup;
                RunObject = Page "Endpoint Request Batch List";
                RunPageLink = "Endpoint Code"=FIELD(Code);
            }
        }
    }
}

