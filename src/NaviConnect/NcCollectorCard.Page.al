page 6151529 "NPR Nc Collector Card"
{
    // NC2.01 /BR  /20160909  CASE 250447 Object created
    // NC2.04 /BR  /20170510  CASE 274524 Removed field Send when Max. Lines

    Caption = 'Nc Collector Card';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Collector";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
                field(Active; Active)
                {
                    ApplicationArea = All;
                }
                field("Max. Lines per Collection"; "Max. Lines per Collection")
                {
                    ApplicationArea = All;
                }
                field("Wait to Send"; "Wait to Send")
                {
                    ApplicationArea = All;
                }
                field("Delete Obsolete Lines"; "Delete Obsolete Lines")
                {
                    ApplicationArea = All;
                }
                field("Delete Sent Collections After"; "Delete Sent Collections After")
                {
                    ApplicationArea = All;
                }
            }
            group(Changes)
            {
                field("Record Modify"; "Record Modify")
                {
                    ApplicationArea = All;
                }
                field("Record Insert"; "Record Insert")
                {
                    ApplicationArea = All;
                }
                field("Record Delete"; "Record Delete")
                {
                    ApplicationArea = All;
                }
                field("Record Rename"; "Record Rename")
                {
                    ApplicationArea = All;
                }
            }
            part(Control6150625; "NPR Nc Collec. Filters")
            {
                SubPageLink = "Collector Code" = FIELD(Code);
                ApplicationArea = All;
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
                RunObject = Page "NPR Nc Collection Lines";
                RunPageLink = "Collector Code" = FIELD(Code);
                ApplicationArea = All;
            }
            action(Collections)
            {
                Caption = 'Collections';
                Image = XMLFileGroup;
                RunObject = Page "NPR Nc Collection List";
                RunPageLink = "Collector Code" = FIELD(Code);
                ApplicationArea = All;
            }
        }
        area(processing)
        {
            action("Send all records as modify")
            {
                Caption = 'Send all records as modify';
                Image = BulletList;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    NcCollectorManagement.CreateModifyCollectionLines(Rec);
                end;
            }
        }
    }

    var
        NcCollectorManagement: Codeunit "NPR Nc Collector Management";
}

