﻿report 6060051 "NPR List of Sales Invoices"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/List of Sales Invoices.rdlc';
    Caption = 'List of Sales Invoices';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

}

