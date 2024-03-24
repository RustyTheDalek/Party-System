function TriggerClientEventResource(eventName, source, ...)
    TriggerClientEvent(GetCurrentResourceName() .. ':' .. eventName, source, ...)
end