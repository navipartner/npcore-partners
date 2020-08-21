page 6150741 "POS Admin. Template List"
{
    // NPR5.51/VB  /20190719  CASE 352582 POS Administrative Templates feature

    Caption = 'POS Admin. Template List';
    CardPageID = "POS Admin. Template Card";
    Editable = false;
    PageType = List;
    SourceTable = "POS Administrative Template";
    UsageCategory = Administration;

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
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Version; Version)
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Persist on Client"; "Persist on Client")
                {
                    ApplicationArea = All;
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
                RunObject = Page "POS Admin. Template Scopes";
                RunPageLink = "POS Admin. Template Id" = FIELD(Id);
            }
        }
    }
}

