codeunit 6059975 "NPR Variety ShowTables"
{
    // VRT1.11/MHA/20160420  CASE 236840 Changed parameter Item to VAR in function ShowVarietyMatrix in order to parse filters
    // VRT1.11/JDH /20160602 CASE 242940 Added function ShowBooleanMatrix to support the new Matrix
    // NPR5.32/JDH /20170510 CASE 274170 Added Subscriber to Matrix Drilldown Event
    // NPR5.36/JDH /20170922 CASE 288696 Returning value for the shown field


    trigger OnRun()
    begin
    end;

    procedure ShowVarietyMatrix(RecRef: RecordRef; var Item: Record Item; ShowFieldNo: Integer)
    var
        VRTMatrix: Page "NPR Variety Matrix";
    begin
        VRTMatrix.SetRecordRef(RecRef, Item, ShowFieldNo);
        VRTMatrix.RunModal;
    end;

    procedure ShowBooleanMatrix(RecRef: RecordRef; var Item: Record Item; ShowFieldNo: Integer)
    var
        VRTMatrixBool: Page "NPR Variety Matrix Bool";
    begin
        //-VRT1.11
        VRTMatrixBool.SetRecordRef(RecRef, Item, ShowFieldNo);
        VRTMatrixBool.RunModal;
        //+VRT1.11
    end;

    procedure LookupLocation(LookupValue: Code[10]) NewLocationCode: Code[10]
    var
        Location: Record Location;
    begin
        Location.SetRange(Code, LookupValue);
        if Location.FindFirst then;
        Location.SetRange(Code);
        if PAGE.RunModal(0, Location) = ACTION::LookupOK then
            exit(Location.Code);
        exit(LookupValue);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059971, 'OnDrillDownEvent', '', false, false)]
    local procedure C6059971_OnDrillDownEvent(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024])
    var
        RecRef: RecordRef;
        FRef: FieldRef;
        VRTShowTable: Codeunit "NPR Variety ShowTables";
    begin
        //-NPR5.32 [274170]
        if TMPVrtBuffer."Variant Code" = '' then
            exit;

        case VrtFieldSetup."Lookup Type" of
            VrtFieldSetup."Lookup Type"::Field:
                begin
                    if Format(TMPVrtBuffer."Record ID (TMP)") <> '' then begin
                        RecRef.Get(TMPVrtBuffer."Record ID (TMP)");
                        FRef := RecRef.Field(VrtFieldSetup."Field No.");
                        case FRef.Relation of
                            DATABASE::Location:
                                begin
                                    //-NPR5.36 [288696]
                                    //VRTShowTable.LookupLocation(FORMAT(FRef.VALUE));
                                    FieldValue := LookupLocation(Format(FRef.Value));
                                    //+NPR5.36 [288696]
                                end;
                        end;
                    end;
                end;
            VrtFieldSetup."Lookup Type"::Internal:
                begin
                end;
            VrtFieldSetup."Lookup Type"::Codeunit:
                begin
                    VrtFieldSetup.TestField("Lookup Object No.");
                    if VrtFieldSetup."Call Codeunit with rec" then begin
                        VrtFieldSetup."Item No. (TMPParm)" := TMPVrtBuffer."Item No.";
                        VrtFieldSetup."Variant Code (TMPParm)" := TMPVrtBuffer."Variant Code";
                        CODEUNIT.Run(VrtFieldSetup."Lookup Object No.", VrtFieldSetup);
                    end else
                        CODEUNIT.Run(VrtFieldSetup."Lookup Object No.");
                end;
        end;
        //+NPR5.32 [274170]
    end;
}

