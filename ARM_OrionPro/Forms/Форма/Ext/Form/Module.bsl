&НаКлиенте
Процедура Сформировать(Команда)
	HTMLПоле = "Формирование отчета запущено...";
	
	
	СформироватьНаСервере();
КонецПроцедуры

&НаСервере
Процедура СформироватьНаСервере()
	ПолучитьТаблицуДанныхИзSQL();
КонецПроцедуры

&НаСервере
Функция ПолучитьТаблицуДанныхИзSQL()
	
	ИмяСервераSQL = "10.2.101.164";
	ПользовательSQL = "odmen";
    ПарольSQL = "123QWEasd";
    БазаДанныхSQL = "Orion";
	
	Подключение = Новый COMОбъект("ADODB.Connection");
	Подключение.ConnectionTimeOut	= 0;
	Подключение.CommandTimeOut	= 0; 
	Подключение.ConnectionString =
            "driver={SQL Server};" +
            "server="+ИмяСервераSQL+";"+
            "uid="+ПользовательSQL+";"+
            "pwd="+ПарольSQL+";"+
            "database="+БазаДанныхSQL+";";
	Подключение.ConnectionTimeout = 30;
	Подключение.CommandTimeout = 600;
	Попытка
		Подключение.Open();
		Сообщить("Успешное подключение!");
	Исключение
		Сообщить(ОписаниеОшибки());
		Возврат Неопределено ;
	КонецПопытки;
	
	ТекстSQL = "SELECT DISTINCT
	|CONVERT(DATETIME,CONVERT(VARCHAR, pLogData.DeviceTime, 104)) AS Дата,
	|pLogData.DeviceTime AS Время,
	|AcessPoint.Name AS Дверь,
	|pLogData.Mode AS Вход1Выход2,
	|pList.Name+' '+pList.FirstName+' '+pList.MidName+' '+pList.TabNumber AS ФИО,
	|PDivision.Name AS Подразделение
	|FROM
	|dbo.pLogData AS pLogData
	|INNER JOIN dbo.pList AS pList
	|ON pLogData.HozOrgan = pList.ID
	|INNER JOIN dbo.AcessPoint AS AcessPoint
	|ON pLogData.DoorIndex = AcessPoint.GIndex
	|INNER JOIN dbo.PDivision AS PDivision
	|ON pList.Section = PDivision.ID
	|WHERE
	|(pLogData.DeviceTime BETWEEN '@DataPar1' AND '@DataPar2')
	|
	|ORDER BY
	|Дверь,
	|ФИО,
	|Время";
	
	ТекстSQL=СтрЗаменить(ТекстSQL,"@DataPar1",Формат(ДатаНачала,"ДФ=dd.MM.yyyy")+" 00:00:00");
	ТекстSQL=СтрЗаменить(ТекстSQL,"@DataPar2",Формат(ДатаОкончания,"ДФ=dd.MM.yyyy")+" 23:59:59");
	
	ТекстSQL = СтрЗаменить(ТекстSQL, "11.01.2018", "01.11.2018");
	
	СоединениеSQL = Новый COMObject("ADODB.Command");
	СоединениеSQL.ActiveConnection = Подключение;
	СоединениеSQL.NamedParameters = True;
	СоединениеSQL.CommandType = 1;
	СоединениеSQL.CommandText = ТекстSQL; 
	СоединениеSQL.CommandTimeout=60;
	
	ЗаписиSQL = Новый ComObject("ADODB.RecordSet");
	
	ЗаписиSQL = СоединениеSQL.Execute();
	
	ТаблицаТЗ_SQL = Новый ТаблицаЗначений;
	Для НомерСтолбца = 0 По ЗаписиSQL.Fields.Count-1 Цикл 
		ИмяСтолбца =ЗаписиSQL.Fields.Item(НомерСтолбца).Name; 
		ТаблицаТЗ_SQL.Колонки.Добавить(ИмяСтолбца);
	КонецЦикла;
	
	
	Пока ЗаписиSQL.EOF = 0 Цикл 		
		НоваяСтрока =  ТаблицаТЗ_SQL.Добавить();
		Для НомерСтолбца = 0 По ЗаписиSQL.Fields.Count-1 Цикл
			НоваяСтрока.Установить(НомерСтолбца,ЗаписиSQL.Fields(НомерСтолбца).Value);
		КонецЦикла;
		
		ЗаписиSQL.MoveNext();
		
	КонецЦикла;
	
	ЗаписиSQL.Close();
	Подключение.Close();
	
	Возврат ТаблицаТЗ_SQL;
	
КонецФункции

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ДатаНачала = НачалоДня(ТекущаяДата());
	ДатаОкончания = КонецДня(ТекущаяДата());
КонецПроцедуры
