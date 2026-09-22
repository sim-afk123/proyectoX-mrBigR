defmodule Main do
  @moduledoc """
  Ejecución del menú principal y consola interactiva.
  """

  # Inicio del programa.
  def main do
    Util.mostrar_mensaje("CYBERPUNK TERMINAL")

    mazo_inicial = [
      HackerTerminal.crear_script(1, "PortScanner", "escaneo", 15),
      HackerTerminal.crear_script(2, "TrojanLite", "virus", 15)
    ]

    max_ram_inicial = 250
    firewall_elegido = seleccionar_objetivo()

    ciclo_juego(mazo_inicial, firewall_elegido, max_ram_inicial, 1)
  end

  # Captura la selección de Firewall.
  defp seleccionar_objetivo do
    Util.mostrar_mensaje("Selecciona el objetivo a atacar:")
    firewalls = HackerTerminal.obtener_firewalls()

    Enum.each(firewalls, fn f ->
      Util.mostrar_mensaje("ID #{f.id} - #{f.nombre} - Antivirus: #{f.hp.antivirus} - Puertos: #{f.hp.puertos} - Nucleo: #{f.hp.nucleo}")
    end)

    id = Util.ingresar("ID del sistema a atacar: ", :entero)

    case HackerTerminal.buscar_firewall(id) do
      nil ->
        Util.mostrar_error("ID no valido, usando Servidor Local por defecto")
        HackerTerminal.buscar_firewall(1)

      fw ->
        Util.mostrar_mensaje("Objetivo seleccionado: #{fw.nombre}")
        fw
    end
  end

  # Bucle interactivo recursivo.
  defp ciclo_juego(mazo, firewall, max_ram, turno) do
    ram_usada = HackerTerminal.calcular_ram_total(mazo)

    Util.mostrar_mensaje("\nTurno #{turno}")
    Util.mostrar_mensaje("Objetivo: #{firewall.nombre}")
    Util.mostrar_mensaje("HP Firewall -> Antivirus: #{Util.formatter(firewall.hp.antivirus * 1.0)} | Puertos: #{Util.formatter(firewall.hp.puertos * 1.0)} | Nucleo: #{Util.formatter(firewall.hp.nucleo * 1.0)}")
    Util.mostrar_mensaje("RAM usada: #{ram_usada} / #{max_ram} MB (Libre: #{max_ram - ram_usada} MB)")
    Util.mostrar_mensaje("1. Ver scripts en RAM")
    Util.mostrar_mensaje("2. Crear nuevo script")
    Util.mostrar_mensaje("3. Modificar script (subir o bajar potencia)")
    Util.mostrar_mensaje("4. Encender / Apagar script (No consume turno)")
    Util.mostrar_mensaje("5. Purgar script")
    Util.mostrar_mensaje("6. Filtrar scripts por tipo")
    Util.mostrar_mensaje("7. Ver diagnostico de daño")
    Util.mostrar_mensaje("8. Ampliar RAM (+50 MB)")
    Util.mostrar_mensaje("9. Cambiar objetivo")
    Util.mostrar_mensaje("10. Atacar Firewall")
    Util.mostrar_mensaje("0. Salir")

    opcion = Util.ingresar("Opcion: ", :entero)

    case opcion do
      1 ->
        HackerTerminal.listar_scripts(mazo)
        ciclo_juego(mazo, firewall, max_ram, turno)

      2 ->
        id = Util.ingresar("ID del script: ", :entero)
        nombre = Util.ingresar("Nombre: ", :texto)
        tipo = Util.ingresar("Tipo (virus/escaneo/exploit): ", :texto)
        potencia = Util.ingresar("Potencia en GW: ", :entero)

        nuevo = HackerTerminal.crear_script(id, nombre, tipo, potencia)

        case HackerTerminal.agregar_script(mazo, nuevo, max_ram) do
          {:ok, mazo_actualizado} ->
            Util.mostrar_mensaje("Script #{nombre} agregado (#{nuevo.ram_mb} MB de RAM)")
            ciclo_juego(mazo_actualizado, firewall, max_ram, turno + 1)

          {:error, msg} ->
            Util.mostrar_error("Error: " <> msg)
            ciclo_juego(mazo, firewall, max_ram, turno)
        end

      3 ->
        id = Util.ingresar("ID del script a modificar: ", :entero)
        inc = Util.ingresar("Cambio de potencia (positivo o negativo): ", :entero)

        case HackerTerminal.modificar_script(mazo, id, inc, max_ram) do
          {:ok, mazo_actualizado} ->
            Util.mostrar_mensaje("Script modificado correctamente")
            ciclo_juego(mazo_actualizado, firewall, max_ram, turno + 1)

          {:error, msg} ->
            Util.mostrar_error("Error: " <> msg)
            ciclo_juego(mazo, firewall, max_ram, turno)
        end

      4 ->
        id = Util.ingresar("ID del script a encender/apagar: ", :entero)

        case HackerTerminal.alternar_estado(mazo, id, max_ram) do
          {:ok, mazo_actualizado} ->
            Util.mostrar_mensaje("Estado del script modificado correctamente")
            ciclo_juego(mazo_actualizado, firewall, max_ram, turno)

          {:error, msg} ->
            Util.mostrar_error("Error: " <> msg)
            ciclo_juego(mazo, firewall, max_ram, turno)
        end

      5 ->
        id = Util.ingresar("ID del script a borrar: ", :entero)

        case HackerTerminal.purgar_script(mazo, id) do
          {:ok, mazo_actualizado} ->
            Util.mostrar_mensaje("Script eliminado de la RAM")
            ciclo_juego(mazo_actualizado, firewall, max_ram, turno + 1)

          {:error, msg} ->
            Util.mostrar_error("Error: " <> msg)
            ciclo_juego(mazo, firewall, max_ram, turno)
        end

      6 ->
        tipo = Util.ingresar("Tipo a filtrar (virus/escaneo/exploit): ", :texto)
        filtrados = HackerTerminal.filtrar_por_tipo(mazo, tipo)
        HackerTerminal.listar_scripts(filtrados)
        ciclo_juego(mazo, firewall, max_ram, turno)

      7 ->
        daño = HackerTerminal.calcular_daño_total_combinado(mazo)

        Util.mostrar_mensaje("Diagnostico de daño estimado (Solo scripts encendidos):")
        Util.mostrar_mensaje("Daño a Antivirus: #{Util.formatter(daño.antivirus)} HP")
        Util.mostrar_mensaje("Daño a Puertos: #{Util.formatter(daño.puertos)} HP")
        Util.mostrar_mensaje("Daño a Nucleo: #{Util.formatter(daño.nucleo)} HP")
        ciclo_juego(mazo, firewall, max_ram, turno)

      8 ->
        nueva_ram = max_ram + 50
        Util.mostrar_mensaje("RAM ampliada a #{nueva_ram} MB")
        ciclo_juego(mazo, firewall, nueva_ram, turno + 1)

      9 ->
        nuevo_fw = seleccionar_objetivo()
        ciclo_juego(mazo, nuevo_fw, max_ram, turno + 1)

      10 ->
        daño = HackerTerminal.calcular_daño_total_combinado(mazo)

        falta_antivirus = firewall.hp.antivirus - daño.antivirus
        falta_puertos = firewall.hp.puertos - daño.puertos
        falta_nucleo = firewall.hp.nucleo - daño.nucleo

        Util.mostrar_mensaje("Atacando a #{firewall.nombre}...")
        Util.mostrar_mensaje("Daño realizado -> Antivirus: #{Util.formatter(daño.antivirus)} | Puertos: #{Util.formatter(daño.puertos)} | Nucleo: #{Util.formatter(daño.nucleo)}")

        if falta_antivirus <= 0 and falta_puertos <= 0 and falta_nucleo <= 0 do
          Util.mostrar_mensaje("Has destruido el firewall #{firewall.nombre} en #{turno} turnos")
        else
          Util.mostrar_mensaje("El ataque fallo. El firewall se ha restaurado por completo")
          Util.mostrar_mensaje("Te falto hacer este daño para romperlo:")

          if falta_antivirus > 0, do: Util.mostrar_mensaje("Faltan #{Util.formatter(falta_antivirus)} HP en Antivirus")
          if falta_puertos > 0, do: Util.mostrar_mensaje("Faltan #{Util.formatter(falta_puertos)} HP en Puertos")
          if falta_nucleo > 0, do: Util.mostrar_mensaje("Faltan #{Util.formatter(falta_nucleo)} HP en Nucleo")

          ciclo_juego(mazo, firewall, max_ram, turno + 1)
        end

      0 ->
        Util.mostrar_mensaje("Saliendo del programa")

      _ ->
        Util.mostrar_error("Opcion invalida")
        ciclo_juego(mazo, firewall, max_ram, turno)
    end
  end
end

Main.main()
