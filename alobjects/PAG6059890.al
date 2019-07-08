page 6059890 "Npm Fields"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager

    Caption = 'Npm Fields';
    DataCaptionExpression = Format(Type);
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Npm Field";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                    Visible = false;
                }
                field("Table No.";"Table No.")
                {
                    Visible = false;
                }
                field("Table Name";"Table Name")
                {
                    Visible = false;
                }
                field("View Code";"View Code")
                {
                    Visible = false;
                }
                field("Field No.";"Field No.")
                {

                    trigger OnAssistEdit()
                    var
                        "Field": Record "Field";
                        NpmField: Record "Npm Field";
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
                          if not NpmField.Get(Type,"Table No.","View Code",Field."No.") then begin
                            NpmField.Init;
                            NpmField.Type := Type;
                            NpmField."Table No." := "Table No.";
                            NpmField."View Code" := "View Code";
                            NpmField."Field No." := Field."No.";
                            NpmField.Insert(true);
                          end;
                        until Field.Next = 0;
                        CurrPage.Update(false);
                    end;
                }
                field("Field Name";"Field Name")
                {
                }
            }
            part(Control6014409;"Npm Caption Subform")
            {
                SubPageLink = "Table No."=FIELD("Table No."),
                              "View Code"=FIELD("View Code"),
                              "Field No."=FIELD("Field No.");
                Visible = (Type = 1);
            }
        }
    }

    actions
    {
    }
}

