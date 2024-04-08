local Translations = {
    error = {
        negative = 'Tentando vender uma quantidade negativa?',
        no_melt = 'Você não me deu nada para derreter...',
        no_items = 'Não há itens suficientes',
    },
    success = {
        sold = 'Você vendeu %{value} x %{value2} por $%{value3}',
        items_received = 'Você recebeu %{value} x %{value2}',
    },
    info = {
        title = 'Casa de Penhores',
        subject = 'Derretendo Itens',
        message = 'Nós terminamos de derreter seus itens. Você pode vir buscá-los a qualquer momento.',
        open_pawn = 'Abrir a Casa de Penhores',
        sell = 'Vender Itens',
        sell_pawn = 'Vender Itens para a Casa de Penhores',
        melt = 'Derreter Itens',
        melt_pawn = 'Abrir a Loja de Derretimento',
        melt_pickup = 'Pegar Itens Derretidos',
        pawn_closed = 'A Casa de Penhores está fechada. Volte entre %{value}:00 AM - %{value2}:00 PM',
        sell_items = 'Preço de Venda $%{value}',
        back = '⬅ Voltar',
        melt_item = 'Derreter %{value}',
        max = 'Quantidade Máxima %{value}',
        submit = 'Derreter',
        melt_wait = 'Dê-me %{value} minutos e terei seus itens derretidos',
    }
}

if GetConvar('qb_locale', 'en') == 'pt-br' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end