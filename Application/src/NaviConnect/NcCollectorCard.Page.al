page 6151529 "NPR Nc Collector Card"
{
    Caption = 'Nc Collector Card';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Collector";
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table Name"; Rec."Table Name")
                {

                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Active; Rec.Active)
                {

                    ToolTip = 'Specifies the value of the Active field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Max. Lines per Collection"; Rec."Max. Lines per Collection")
                {

                    ToolTip = 'Specifies the value of the Max. Lines per Collection field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Wait to Send"; Rec."Wait to Send")
                {

                    ToolTip = 'Specifies the value of the Wait to Send field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Delete Obsolete Lines"; Rec."Delete Obsolete Lines")
                {

                    ToolTip = 'Specifies the value of the Delete Obsolete Lines field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Delete Sent Collections After"; Rec."Delete Sent Collections After")
                {

                    ToolTip = 'Specifies the value of the Delete Sent Collections After field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
            group(Changes)
            {
                Caption = 'Changes';
                field("Record Modify"; Rec."Record Modify")
                {

                    ToolTip = 'Specifies the value of the Modify field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Record Insert"; Rec."Record Insert")
                {

                    ToolTip = 'Specifies the value of the Insert field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Record Delete"; Rec."Record Delete")
                {

                    ToolTip = 'Specifies the value of the Delete field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Record Rename"; Rec."Record Rename")
                {

                    ToolTip = 'Specifies the value of the Rename field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
            part(Control6150625; "NPR Nc Collec. Filters")
            {
                SubPageLink = "Collector Code" = FIELD(Code);
                ApplicationArea = NPRNaviConnect;

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
                ToolTip = 'Executes the Collection Lines action';
                ApplicationArea = NPRNaviConnect;
            }
            action(Collections)
            {
                Caption = 'Collections';
                Image = XMLFileGroup;
                RunObject = Page "NPR Nc Collection List";
                RunPageLink = "Collector Code" = FIELD(Code);
                ToolTip = 'Executes the Collections action';
                ApplicationArea = NPRNaviConnect;
            }
        }
        area(processing)
        {
            action("Send all records as modify")
            {
                Caption = 'Send all records as modify';
                Image = BulletList;
                ToolTip = 'Executes the Send all records as modify action';
                ApplicationArea = NPRNaviConnect;

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

