page 6151529 "Nc Collector Card"
{
    // NC2.01 /BR  /20160909  CASE 250447 Object created
    // NC2.04 /BR  /20170510  CASE 274524 Removed field Send when Max. Lines

    Caption = 'Nc Collector Card';
    PageType = Card;
    SourceTable = "Nc Collector";

    layout
    {
        area(content)
        {
            group(General)
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
                field("Max. Lines per Collection";"Max. Lines per Collection")
                {
                }
                field("Wait to Send";"Wait to Send")
                {
                }
                field("Delete Obsolete Lines";"Delete Obsolete Lines")
                {
                }
                field("Delete Sent Collections After";"Delete Sent Collections After")
                {
                }
            }
            group(Changes)
            {
                field("Record Modify";"Record Modify")
                {
                }
                field("Record Insert";"Record Insert")
                {
                }
                field("Record Delete";"Record Delete")
                {
                }
                field("Record Rename";"Record Rename")
                {
                }
            }
            part(Control6150625;"Nc Collector Filters")
            {
                SubPageLink = "Collector Code"=FIELD(Code);
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Collection Lines")
            {
                Caption = 'Collection Lines';
                Image = XMLFile;
                RunObject = Page "Nc Collection Lines";
                RunPageLink = "Collector Code"=FIELD(Code);
            }
            action(Collections)
            {
                Caption = 'Collections';
                Image = XMLFileGroup;
                RunObject = Page "Nc Collection List";
                RunPageLink = "Collector Code"=FIELD(Code);
            }
        }
        area(processing)
        {
            action("Send all records as modify")
            {
                Caption = 'Send all records as modify';
                Image = BulletList;

                trigger OnAction()
                begin
                    NcCollectorManagement.CreateModifyCollectionLines(Rec);
                end;
            }
        }
    }

    var
        NcCollectorManagement: Codeunit "Nc Collector Management";
}

