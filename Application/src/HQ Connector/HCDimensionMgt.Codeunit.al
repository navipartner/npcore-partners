codeunit 6150917 "NPR HC Dimension Mgt."
{
    var
        DimensionMgt: Codeunit DimensionManagement;

    [EventSubscriber(ObjectType::Table, 352, 'OnAfterInsertEvent', '', true, true)]
    local procedure DefaultDimensionOnAfterInsert(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if not RunTrigger then
            exit;
        GLSetup.Get();
        if Rec."Dimension Code" = GLSetup."Global Dimension 1 Code" then
            UpdateGlobalDimCode(1, Rec."Table ID", Rec."No.", Rec."Dimension Value Code");
        if Rec."Dimension Code" = GLSetup."Global Dimension 2 Code" then
            UpdateGlobalDimCode(2, Rec."Table ID", Rec."No.", Rec."Dimension Value Code");
    end;

    [EventSubscriber(ObjectType::Table, 352, 'OnAfterModifyEvent', '', true, true)]
    local procedure DefaultDimensionOnAfterModify(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if not RunTrigger then
            exit;
        GLSetup.Get();
        if Rec."Dimension Code" = GLSetup."Global Dimension 1 Code" then
            UpdateGlobalDimCode(1, Rec."Table ID", Rec."No.", Rec."Dimension Value Code");
        if Rec."Dimension Code" = GLSetup."Global Dimension 2 Code" then
            UpdateGlobalDimCode(2, Rec."Table ID", Rec."No.", Rec."Dimension Value Code");
    end;

    [EventSubscriber(ObjectType::Table, 352, 'OnAfterDeleteEvent', '', true, true)]
    local procedure DefaultDimensionOnAfterDelete(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if not RunTrigger then
            exit;
        GLSetup.Get();
        if Rec."Dimension Code" = GLSetup."Global Dimension 1 Code" then
            UpdateGlobalDimCode(1, Rec."Table ID", Rec."No.", '');
        if Rec."Dimension Code" = GLSetup."Global Dimension 2 Code" then
            UpdateGlobalDimCode(2, Rec."Table ID", Rec."No.", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, 408, 'OnAfterSetupObjectNoList', '', true, true)]
    local procedure DimensionMgtOnAfterSetupObjectNoList(var TempAllObjWithCaption: Record AllObjWithCaption temporary)
    begin
        DimensionMgt.InsertObject(TempAllObjWithCaption, DATABASE::"NPR HC Register");
    end;

    procedure TypeToTable(Type: Option "G/L",Item,"Item Group",Repair,,Payment,"Open/Close",BOM,Customer,Comment): Integer
    begin
        case Type of
            Type::"G/L":
                exit(DATABASE::"G/L Account");
            Type::Item:
                exit(DATABASE::Item);
            Type::"Item Group":
                exit(0);
            Type::Repair:
                exit(0);
            Type::Payment:
                exit(DATABASE::"NPR HC Payment Type POS");
            Type::"Open/Close":
                exit(0);
            Type::BOM:
                exit(DATABASE::Item);
            Type::Customer:
                exit(DATABASE::Customer);
            Type::Comment:
                exit(0);
        end;
    end;

    procedure UpdateGlobalDimCode(GlobalDimCodeNo: Integer; TableID: Integer; No: Code[20]; NewDimValue: Code[20])
    begin
        case TableID of
            DATABASE::"NPR HC Register":
                UpdateHCRegisterGlobalDimCode(GlobalDimCodeNo, No, NewDimValue);
        end;
    end;

    procedure UpdateHCRegisterGlobalDimCode(GlobalDimCodeNo: Integer; RegisterNo: Code[20]; NewDimValue: Code[20])
    var
        HCRegister: Record "NPR HC Register";
    begin
        if HCRegister.Get(RegisterNo) then begin
            case GlobalDimCodeNo of
                1:
                    HCRegister."Global Dimension 1 Code" := NewDimValue;
                2:
                    HCRegister."Global Dimension 2 Code" := NewDimValue;
            end;
            HCRegister.Modify(true);
        end;
    end;
}

