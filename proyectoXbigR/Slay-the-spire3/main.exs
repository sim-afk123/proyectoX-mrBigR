defmodule Main do
  @moduledoc """
  Ejecucion del ciclo de juego narrativo basado en decisiones.
  """

  def main do
    Util.mostrar_mensaje("ELIXIR DUNGEON: LA MAZMORRA DE JHONATAN")

    # Estado del jugador
    jugador = %{hp: 100, oro: 30}

    # Inventario inicial recibido de la historia
    inventario_inicial = [
      DungeonNarrativo.crear_item(1, "Antorcha de Mano", "herramienta", 5),
      DungeonNarrativo.crear_item(2, "Llave Oxidadora", "llave", 1)
    ]

    ciclo_juego(jugador, inventario_inicial, 1)
  end

  defp ciclo_juego(jugador, inventario, sala) do
    Util.mostrar_mensaje("\n----------------------------------------")
    Util.mostrar_mensaje("MISION ACTUAL: SALA #{sala} | Salud HP: #{jugador.hp} | Oro: #{jugador.oro}")
    Util.mostrar_mensaje("----------------------------------------")

    if jugador.hp <= 0 do
      Util.mostrar_mensaje("Has caido en la mazmorra. Jhonatan ha ganado esta vez. FIN DEL JUEGO.")
    else
      Util.mostrar_mensaje("1. Avanzar en la Mision / Explorar Sala")
      Util.mostrar_mensaje("2. Inspeccionar Mochila (Read)")
      Util.mostrar_mensaje("3. Modificar durabilidad/usos de objeto (Update)")
      Util.mostrar_mensaje("4. Descartar objeto de la mochila (Delete)")
      Util.mostrar_mensaje("5. Filtrar mochila por tipo (Enum.filter)")
      Util.mostrar_mensaje("6. Consultar durabilidad total acumulada (Enum.reduce)")
      Util.mostrar_mensaje("0. Abandonar la mazmorra")

      opcion = Util.ingresar("Opcion > ", :entero)

      case opcion do
        1 ->
          {nuevo_jugador, nuevo_inv, nueva_sala} = procesar_mision(jugador, inventario, sala)
          ciclo_juego(nuevo_jugador, nuevo_inv, nueva_sala)

        2 ->
          DungeonNarrativo.listar_items(inventario)
          ciclo_juego(jugador, inventario, sala)

        3 ->
          id = Util.ingresar("ID del objeto a modificar: ", :entero)
          cambio = Util.ingresar("Cambio de durabilidad (+ o -): ", :entero)

          case DungeonNarrativo.modificar_durabilidad(inventario, id, cambio) do
            {:ok, inv_act} ->
              Util.mostrar_mensaje("Durabilidad modificada correctamente.")
              ciclo_juego(jugador, inv_act, sala)

            {:error, msg} ->
              Util.mostrar_error("Error: " <> msg)
              ciclo_juego(jugador, inventario, sala)
          end

        4 ->
          id = Util.ingresar("ID del objeto a descartar: ", :entero)

          case DungeonNarrativo.descartar_item(inventario, id) do
            {:ok, inv_act} ->
              Util.mostrar_mensaje("Objeto descartado de la mochila.")
              ciclo_juego(jugador, inv_act, sala)

            {:error, msg} ->
              Util.mostrar_error("Error: " <> msg)
              ciclo_juego(jugador, inventario, sala)
          end

        5 ->
          tipo = Util.ingresar("Tipo a filtrar (llave/herramienta/artefacto): ", :texto)
          filtrados = DungeonNarrativo.filtrar_por_tipo(inventario, tipo)
          DungeonNarrativo.listar_items(filtrados)
          ciclo_juego(jugador, inventario, sala)

        6 ->
          dur_total = DungeonNarrativo.calcular_durabilidad_total(inventario)
          Util.mostrar_mensaje("Durabilidad total acumulada en herramientas: #{dur_total} usos")
          ciclo_juego(jugador, inventario, sala)

        0 ->
          Util.mostrar_mensaje("Has salido de la mazmorra.")

        _ ->
          Util.mostrar_error("Opcion invalida")
          ciclo_juego(jugador, inventario, sala)
      end
    end
  end

  # MISIONES NARRATIVAS Y OBTENCIÓN AUTOMÁTICA DE OBJETOS
  defp procesar_mision(jugador, inventario, sala) do
    case sala do
      1 ->
        Util.mostrar_mensaje("\n[MISION 1: LA ENTRADA SELLADA DE JHONATAN]")
        Util.mostrar_mensaje("Te encuentras frente a un porton de hierro cerrado. Hay una inscripcion:")
        Util.mostrar_mensaje("'Solo aquellos con la llave adecuada o herramientas podran entrar al dominio de Jhonatan.'")
        Util.mostrar_mensaje("1. Usar una 'llave' de tu inventario")
        Util.mostrar_mensaje("2. Forzar la puerta usando una 'herramienta'")
        Util.mostrar_mensaje("3. Intentar derribar la puerta a patadas")

        decision = Util.ingresar("Tu decision: ", :entero)

        case decision do
          1 ->
            if DungeonNarrativo.tiene_tipo_item?(inventario, "llave") do
              Util.mostrar_mensaje("Usas tu llave. El porton se abre suavemente y entras sin sufrir daño.")
              {jugador, inventario, sala + 1}
            else
              Util.mostrar_error("No llevas ninguna llave en tu mochila. Pierdes tiempo buscando otra via.")
              {jugador, inventario, sala}
            end

          2 ->
            if DungeonNarrativo.tiene_tipo_item?(inventario, "herramienta") do
              Util.mostrar_mensaje("Utilizas tu herramienta para hacer palanca. Logras abrirla pero haces ruido.")
              {jugador, inventario, sala + 1}
            else
              Util.mostrar_error("No tienes herramientas para hacer palanca.")
              {jugador, inventario, sala}
            end

          _ ->
            Util.mostrar_mensaje("Intentas dar una patada. El porton no se mueve y te lastimas el pie (-15 HP).")
            {%{jugador | hp: jugador.hp - 15}, inventario, sala}
        end

      2 ->
        Util.mostrar_mensaje("\n[MISION 2: EL ACERTIJO DEL INFORMANTE]")
        Util.mostrar_mensaje("Un informante de la mazmorra te susurra desde las sombras:")
        Util.mostrar_mensaje("'Jhonatan ha escondido un mapa magico mas adelante. Si me das 20 monedas te lo entregare.'")
        Util.mostrar_mensaje("1. Pagar 20 monedas para recibir el 'Mapa del Pasaje'")
        Util.mostrar_mensaje("2. Ignorar al informante y buscar el pasaje solo")

        decision = Util.ingresar("Tu decision: ", :entero)

        case decision do
          1 ->
            if jugador.oro >= 20 do
              mapa = DungeonNarrativo.crear_item(50, "Mapa del Pasaje", "artefacto", 3)
              {:ok, inv_act} = DungeonNarrativo.agregar_item(inventario, mapa)
              Util.mostrar_mensaje("Le pagas al informante. Has recibido el 'Mapa del Pasaje' en tu mochila.")
              {%{jugador | oro: jugador.oro - 20}, inv_act, sala + 1}
            else
              Util.mostrar_error("No tienes suficiente oro para el trato.")
              {jugador, inventario, sala + 1}
            end

          _ ->
            Util.mostrar_mensaje("Decides buscar por tu cuenta. Tropiezas con una trampa de dardos (-20 HP).")
            {%{jugador | hp: jugador.hp - 20}, inventario, sala + 1}
        end

      3 ->
        Util.mostrar_mensaje("\n[MISION FINAL: ENCUENTRO CON JHONATAN]")
        Util.mostrar_mensaje("Llegas a la camara central. Jhonatan te espera sentado en su trono.")
        Util.mostrar_mensaje("Jhonatan dice: 'Has llegado lejos... pero solo aquellos que posean el Mapa del Pasaje podran salir de aqui.'")
        Util.mostrar_mensaje("1. Mostrar el 'Mapa del Pasaje' (artefacto) de tu mochila")
        Util.mostrar_mensaje("2. Negociar tu libertad ofreciendole 30 monedas de oro")
        Util.mostrar_mensaje("3. Intentar huir corriendo")

        decision = Util.ingresar("Tu decision: ", :entero)

        case decision do
          1 ->
            if DungeonNarrativo.tiene_tipo_item?(inventario, "artefacto") do
              Util.mostrar_mensaje("Muestras el Mapa del Pasaje a Jhonatan. Queda impresionado y te concede el paso libre.")
              Util.mostrar_mensaje("¡HAS COMPLETADO LA MAZMORRA Y SUPERADO EL DESAFIO DE JHONATAN!")
              {jugador, inventario, sala + 1}
            else
              Util.mostrar_error("No llevas el mapa en tu mochila.")
              Util.mostrar_mensaje("Jhonatan se molesta por tu audacia y te ataca (-30 HP).")
              {%{jugador | hp: jugador.hp - 30}, inventario, sala}
            end

          2 ->
            if jugador.oro >= 30 do
              Util.mostrar_mensaje("Jhonatan acepta tu tributo de 30 monedas y abre la puerta. ¡Has escapado!")
              {%{jugador | oro: jugador.oro - 30}, inventario, sala + 1}
            else
              Util.mostrar_error("No tienes 30 monedas. Jhonatan te ataca por intentar engañarlo (-25 HP).")
              {%{jugador | hp: jugador.hp - 25}, inventario, sala}
            end

          _ ->
            Util.mostrar_mensaje("Intentas huir pero Jhonatan te lanza un hechizo (-35 HP).")
            {%{jugador | hp: jugador.hp - 35}, inventario, sala}
        end

      _ ->
        Util.mostrar_mensaje("\n[FIN DE LA AVENTURA]")
        Util.mostrar_mensaje("Has completado todas las misiones de la mazmorra.")
        {jugador, inventario, sala}
    end
  end
end

Main.main()
