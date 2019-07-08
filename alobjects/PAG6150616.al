page 6150616 "POS Unit List"
{
    // NPR5.29/AP  /20170126  CASE 261728 Recreated ENU-captions
    // NPR5.34/KENU/20170623  CASE 282023 Added Page POS Unit Identity List to Navigate
    // NPR5.36/BR  /20170810  CASE 277096 Added Actions to navigate to Entries and Legder Registers
    // NPR5.38/BR  /20171214  CASE 299888 Changed ENU Caption from POS Ledger Register to POS Period Register
    // NPR5.40/TS  /20180105  CASE  300893 Action Containers cannot have caption
    // NPR5.40/TSA /20180228  CASE 306581 Added button Create Checkpoint
    // NPR5.45/MHA /20180803  CASE 323705 Added fields 300, 305, 310 to enable overload of Item Price functionality
    // NPR5.45/MHA /20180814  CASE 319706 Added field 200 Ean Box Sales Setup
    // NPR5.45/MHA /20180820 CASE 321266 Added field 205 "POS Sales Workflow Set"

    Caption = 'POS Unit List';
    CardPageID = "POS Unit Card";
    Editable = false;
    PageType = List;
    SourceTable = "POS Unit";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field(Name;Name)
                {
                }
                field("POS Store Code";"POS Store Code")
                {
                }
                field("Global Dimension 1 Code";"Global Dimension 1 Code")
                {
                }
                field("Global Dimension 2 Code";"Global Dimension 2 Code")
                {
                }
                field(Status;Status)
                {
                    Visible = false;
                }
                field("Ean Box Sales Setup";"Ean Box Sales Setup")
                {
                }
                field("POS Sales Workflow Set";"POS Sales Workflow Set")
                {
                }
                field("Item Price Codeunit ID";"Item Price Codeunit ID")
                {
                    Visible = false;
                }
                field("Item Price Codeunit Name";"Item Price Codeunit Name")
                {
                    Visible = false;
                }
                field("Item Price Function";"Item Price Function")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("POS Unit Identity List")
            {
                Caption = 'POS Unit Identity List';
                Image = List;
                RunObject = Page "POS Unit Identity List";
            }
            action("POS Period Registers")
            {
                Caption = 'POS Period Registers';
                Image = Register;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "POS Period Register List";
                RunPageLink = "POS Unit No."=FIELD("No.");
            }
            action("POS Entries")
            {
                Caption = 'POS Entries';
                Image = LedgerEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "POS Entry List";
                RunPageLink = "POS Unit No."=FIELD("No.");
            }
            action("POS Unit Bins")
            {
                Caption = 'POS Unit Bins';
                Image = List;
                RunObject = Page "POS Unit to Bin Relation";
                RunPageLink = "POS Unit No."=FIELD("No.");
            }
            action(Workshifts)
            {
                Caption = 'Workshifts';
                Ellipsis = true;
                Image = Sales;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "POS Workshift Checkpoints";
                RunPageLink = "POS Unit No."=FIELD("No.");
            }
        }
        area(processing)
        {
            action("End Workshift (Prel)")
            {
                Caption = 'End Workshift (Prel)';
                Ellipsis = true;
                Image = Sales;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    CreateCheckpointWorker (true, true, "No.");
                end;
            }
        }
    }

    local procedure CreateCheckpoint(UnitNo: Code[20])
    var
        NPRetailSetup: Record "NP Retail Setup";
    begin
        if not (NPRetailSetup.Get ())
          then exit;

        if (NPRetailSetup."Advanced POS Entries Activated") then
          CreateCheckpointWorker (NPRetailSetup."Advanced Posting Activated", false, UnitNo);
    end;

    local procedure CreateCheckpointWorker(UsePosEntry: Boolean;WithPosting: Boolean;UnitNo: Code[20])
    var
        POSCheckpointMgr: Codeunit "POS Workshift Checkpoint";
    begin
        POSCheckpointMgr.CloseWorkshift (UsePosEntry, WithPosting, "No.");
    end;
}

