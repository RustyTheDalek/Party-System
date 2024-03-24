function TriggerServerEventResource(eventName, source, ...)
    print("Trigger Server Event")
    print(GetCurrentResourceName() .. ':' .. eventName)
    TriggerServerEvent(GetCurrentResourceName() .. ':' .. eventName, source, ...)
end