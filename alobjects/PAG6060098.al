page 6060098 "Ean Box Setup Events"
{
    // NPR5.32/NPKNAV/20170526  CASE 272577 Transport NPR5.32 - 26 May 2017
    // NPR5.40/VB  /20180307 CASE 306347 Force-invoking physical action discovery.
    // NPR5.45/MHA /20180814  CASE 319706 Reworked Identifier Dissociation to Ean Box Event Handler
    // NPR5.47/MHA /20181024  CASE 333512 Added field 10 Priority

    Caption = 'Ean Box Setup Events';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Ean Box Setup Event";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Event Code";"Event Code")
                {
                }
                field("Module Name";"Module Name")
                {
                    Editable = false;
                }
                field("Event Description";"Event Description")
                {
                }
                field(Enabled;Enabled)
                {
                }
                field(Priority;Priority)
                {
                }
                field("Action Code";"Action Code")
                {
                    Editable = false;
                }
                field("Action Description";"Action Description")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Parameters)
            {
                Caption = 'Parameters';
                Image = List;

                trigger OnAction()
                var
                    EanBoxEvent: Record "Ean Box Event";
                    EanBoxParameter: Record "Ean Box Parameter";
                    EanBoxSetupMgt: Codeunit "Ean Box Setup Mgt.";
                begin
                    EanBoxSetupMgt.InitEanBoxSetupEventParameters(Rec);
                    EanBoxParameter.SetRange("Setup Code","Setup Code");
                    EanBoxParameter.SetRange("Event Code","Event Code");
                    PAGE.Run(0,EanBoxParameter);
                end;
            }
        }
    }
}

