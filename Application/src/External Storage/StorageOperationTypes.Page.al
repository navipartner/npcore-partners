page 6184893 "NPR Storage Operation Types"
{
    // NPR5.54/ALST/20200311 CASE 394895 Object created

    Caption = 'Storage Operation Types';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Storage Operation Type";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Storage Type"; "Storage Type")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Operation Code"; "Operation Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(RunOperation)
            {
                Caption = 'Run';
                Image = Continue;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    ExternalStorageInterface: Codeunit "NPR External Storage Interface";
                begin
                    SetPosition(GetPosition);

                    TempStorageOperationParameter.Reset;
                    TempStorageOperationParameter.SetRange("Storage Type", "Storage Type");
                    TempStorageOperationParameter.SetRange("Operation Code", "Operation Code");
                    if TempStorageOperationParameter.FindSet then;

                    ExternalStorageInterface.HandleOperation(StorageID, Rec, TempStorageOperationParameter);
                end;
            }
            action(Parameters)
            {
                Caption = 'Parameters';
                Image = SelectEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    FieldNumber: Integer;
                begin
                    TempStorageOperationParameter.Reset;
                    TempStorageOperationParameter.FilterGroup(2);
                    TempStorageOperationParameter.SetRange("Storage Type", "Storage Type");
                    TempStorageOperationParameter.SetRange("Operation Code", "Operation Code");
                    TempStorageOperationParameter.FilterGroup(0);

                    FieldNumber := TempStorageOperationParameter.FieldNo("Parameter Value");
                    PAGE.RunModal(PAGE::"NPR Storage Operation Param.", TempStorageOperationParameter, FieldNumber);
                end;
            }
            action(CopyParamToClipboard)
            {
                Caption = 'Create & Copy Job Parameter';
                Image = SelectEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    ExternalStorageJobQueue: Codeunit "NPR External Storage Job Queue";
                begin
                    SetPosition(GetPosition);

                    TempStorageOperationParameter.Reset;
                    TempStorageOperationParameter.SetRange("Storage Type", "Storage Type");
                    TempStorageOperationParameter.SetRange("Operation Code", "Operation Code");

                    ExternalStorageJobQueue.GenerateJobQueueParameter(StorageID, Rec, TempStorageOperationParameter);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        ExternalStorageInterface: Codeunit "NPR External Storage Interface";
    begin
        ExternalStorageInterface.OnDiscoverStorageOperation(Rec);
    end;

    var
        TempStorageOperationParameter: Record "NPR Storage Operation Param." temporary;
        StorageID: Text;

    procedure HandleStorageID(StorageCode: Text[24])
    begin
        if StorageCode > '' then
            StorageID := StorageCode;
    end;
}

