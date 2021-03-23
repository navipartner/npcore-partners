codeunit 6060058 "NPR Item Wksht. TaskQueue Mgt."
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        Register: Boolean;
        BatchName: Text;
        TemplateName: Text;
    begin
        // Expected "Parameter String" like TEMPLATE_NAME=template,BATCH_NAME=batch,REGISTER_ITEM_WKSHT
        JQParamStrMgt.Parse(Rec."Parameter String");

        Register := JQParamStrMgt.GetBoolean(ParamRegisterItemWksht());
        evaluate(TemplateName, JQParamStrMgt.GetText(ParamTemplateName()));
        evaluate(BatchName, JQParamStrMgt.GetText(ParamBatchName()));

        Commit();
        if Register then
            RegisterItemWkshtBatch(TemplateName, BatchName);
    end;

    procedure ParamTemplateName(): Text
    begin
        exit('TEMPLATE_NAME');
    end;

    procedure ParamBatchName(): Text
    begin
        exit('BATCH_NAME');
    end;

    procedure ParamRegisterItemWksht(): Text
    begin
        exit('REGISTER_ITEM_WKSHT');
    end;

    local procedure RegisterItemWkshtBatch(TemplateName: Text; BatchName: Text)
    var
        ItemWkshtLine: Record "NPR Item Worksheet Line";
    begin
        ItemWkshtLine.FilterGroup(2);
        ItemWkshtLine.SetRange("Worksheet Template Name", TemplateName);
        ItemWkshtLine.SetRange("Worksheet Name", BatchName);
        ItemWkshtLine.FilterGroup(0);

        if not ItemWkshtLine.IsEmpty() then
            Codeunit.Run(Codeunit::"NPR Item Wsht.-Regist. Batch", ItemWkshtLine);
    end;
}

