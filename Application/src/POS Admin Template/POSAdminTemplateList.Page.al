page 6150741 "NPR POS Admin. Template List"
{
    // NPR5.51/VB  /20190719  CASE 352582 POS Administrative Templates feature

    Caption = 'POS Admin. Template List';
    CardPageID = "NPR POS Admin. Template Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Admin. Template";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id; Id)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Id field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Version; Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Persist on Client"; "Persist on Client")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Persist on Client field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Scopes)
            {
                Caption = 'Scopes';
                Image = UserInterface;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Admin. Template Scopes";
                RunPageLink = "POS Admin. Template Id" = FIELD(Id);
                ApplicationArea = All;
                ToolTip = 'Executes the Scopes action';
            }
        }
    }
}

