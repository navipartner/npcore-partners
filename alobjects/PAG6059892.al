page 6059892 "Npm View Conditions"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager

    Caption = 'View Conditions';
    DelayedInsert = true;
    InstructionalText = 'Define Field Value criterias for the current Page View';
    LinksAllowed = false;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "Npm View Condition";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No.";"Field No.")
                {

                    trigger OnAssistEdit()
                    var
                        "Field": Record "Field";
                        NpmViewCondition: Record "Npm View Condition";
                        NpmNavFieldList: Page "Npm Nav Field List";
                    begin
                        Clear(NpmNavFieldList);
                        Field.SetRange(TableNo,"Table No.");
                        NpmNavFieldList.SetTableView(Field);
                        NpmNavFieldList.LookupMode(true);
                        if NpmNavFieldList.RunModal <> ACTION::LookupOK then
                          exit;

                        NpmNavFieldList.FindMarked(Field);
                        if Field.IsEmpty then
                          exit;

                        Field.FindSet;
                        repeat
                          if not NpmViewCondition.Get("Table No.","View Code",Field."No.") then begin
                            NpmViewCondition.Init;
                            NpmViewCondition."Table No." := "Table No.";
                            NpmViewCondition."View Code" := "View Code";
                            NpmViewCondition."Field No." := Field."No.";
                            NpmViewCondition.Insert(true);
                          end;
                        until Field.Next = 0;
                        CurrPage.Update(false);
                    end;
                }
                field("Field Name";"Field Name")
                {
                }
                field(Value;Value)
                {
                }
            }
        }
    }

    actions
    {
    }
}

