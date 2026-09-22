defmodule HackerTerminal do
 @moduledoc """
  Módulo de lógica central para la simulación Cyberpunk Terminal.

  Gestiona la administración de scripts de hackeo, el control de memoria RAM
  y la evaluación de daño sobre las capas de los Firewalls.

  ### Puntos clave:
  * **Tipos de Scripts:** Clasificación en `virus`, `escaneo` y `exploit` con porcentajes de daño específicos.
  * **Control de RAM:** Cálculo automático del consumo según la potencia y validación de límites.
  * **Operaciones CRUD:** Creación, lectura, modificación de potencia/estado y eliminación de scripts en memoria.
  * **Simulación de Ataque:** Acumulación de daño combinado sobre los sistemas objetivo usando funciones de `Enum`.
  """

  # Calcula uso de RAM según potencia.
  def calcular_ram_script(potencia) do
    trunc(potencia * 2.5)
  end

  # Lista de Firewalls a atacar.
  def obtener_firewalls do
    [
      %{id: 1, nombre: "Servidor Local", hp: %{antivirus: 20, puertos: 20, nucleo: 20}},
      %{id: 2, nombre: "Red Corporativa", hp: %{antivirus: 30, puertos: 60, nucleo: 30}},
      %{id: 3, nombre: "Filtro Antivirus Pro", hp: %{antivirus: 70, puertos: 30, nucleo: 20}},
      %{id: 4, nombre: "Nodo Militar", hp: %{antivirus: 40, puertos: 30, nucleo: 90}},
      %{id: 5, nombre: "Servidor de Banco", hp: %{antivirus: 80, puertos: 40, nucleo: 80}},
      %{id: 6, nombre: "Servidor de Big R", hp: %{antivirus: 120, puertos: 120, nucleo: 120}}
    ]
  end

  # Busca un Firewall por ID.
  def buscar_firewall(id) do
    Enum.find(obtener_firewalls(), fn f -> f.id == id end)
  end

  # Distribuye el daño por tipo de script.
  def calcular_daño_script(script) do
    if not script.activo do
      %{antivirus: 0.0, puertos: 0.0, nucleo: 0.0}
    else
      case script.tipo do
        "virus" ->
          %{
            antivirus: script.potencia * 0.60,
            puertos: script.potencia * 0.30,
            nucleo: script.potencia * 0.10
          }

        "escaneo" ->
          %{
            antivirus: script.potencia * 0.20,
            puertos: script.potencia * 0.70,
            nucleo: script.potencia * 0.10
          }

        "exploit" ->
          %{
            antivirus: script.potencia * 0.10,
            puertos: script.potencia * 0.20,
            nucleo: script.potencia * 0.70
          }

        _ ->
          %{antivirus: 0.0, puertos: 0.0, nucleo: 0.0}
      end
    end
  end

  # [CREATE] Crea un nuevo mapa de script.
  def crear_script(id, nombre, tipo, potencia) do
    tipo_norm = String.downcase(tipo)

    %{
      id: id,
      nombre: nombre,
      tipo: tipo_norm,
      potencia: potencia,
      activo: true,
      ram_mb: calcular_ram_script(potencia)
    }
  end

  # [CREATE] Agrega el script a la RAM si no excede el límite.
  def agregar_script(mazo, nuevo_script, max_ram) do
    ram_actual = calcular_ram_total(mazo)

    cond do
      buscar_script_por_id(mazo, nuevo_script.id) != nil ->
        {:error, "Ya existe un script registrado con la id #{nuevo_script.id}"}

      nuevo_script.tipo not in ["virus", "escaneo", "exploit"] ->
        {:error, "Tipo de script no valido. Use virus, escaneo o exploit"}

      ram_actual + nuevo_script.ram_mb > max_ram ->
        {:error, "RAM insuficiente. Libre: #{max_ram - ram_actual} MB, Requerido: #{nuevo_script.ram_mb} MB"}

      true ->
        {:ok, [nuevo_script | mazo]}
    end
  end

  # [READ] Imprime todos los scripts en RAM con Enum.each.
  def listar_scripts(mazo) do
    if mazo == [] do
      Util.mostrar_mensaje("La memoria RAM esta vacia")
    else
      Util.mostrar_mensaje("Scripts cargados en RAM:")
      Enum.each(mazo, fn s ->
        estado_str = if s.activo, do: "ENCENDIDO", else: "APAGADO"
        ram_usada = if s.activo, do: s.ram_mb, else: 0
        Util.mostrar_mensaje("ID #{s.id} - #{s.nombre} - Tipo: #{s.tipo} - Potencia: #{s.potencia} GW - RAM: #{ram_usada} MB (#{s.ram_mb} MB max) - Estado: #{estado_str}")
      end)
    end
  end

  # [READ] Busca script por ID usando Enum.find.
  def buscar_script_por_id(mazo, id) do
    Enum.find(mazo, fn script -> script.id == id end)
  end

  # [READ] Filtra scripts por tipo usando Enum.filter.
  def filtrar_por_tipo(mazo, tipo_buscado) do
    Enum.filter(mazo, fn script ->
      script.tipo == String.downcase(tipo_buscado)
    end)
  end

  # Suma la RAM de scripts encendidos usando Enum.reduce.
  def calcular_ram_total(mazo) do
    Enum.reduce(mazo, 0, fn script, ac ->
      if script.activo do
        script.ram_mb + ac
      else
        ac
      end
    end)
  end

  # Suma el daño total por capa usando Enum.reduce.
  def calcular_daño_total_combinado(mazo) do
    Enum.reduce(mazo, %{antivirus: 0.0, puertos: 0.0, nucleo: 0.0}, fn script, acc ->
      daño = calcular_daño_script(script)

      %{
        antivirus: acc.antivirus + daño.antivirus,
        puertos: acc.puertos + daño.puertos,
        nucleo: acc.nucleo + daño.nucleo
      }
    end)
  end

  # [UPDATE] Prende o apaga un script usando Enum.map.
  def alternar_estado(mazo, id, max_ram) do
    script_existente = buscar_script_por_id(mazo, id)

    case script_existente do
      nil ->
        {:error, "Script no encontrado en la RAM"}

      s ->
        if not s.activo do
          ram_actual = calcular_ram_total(mazo)

          if ram_actual + s.ram_mb > max_ram do
            {:error, "No hay suficiente RAM libre para encender el script (requiere #{s.ram_mb} MB)"}
          else
            nuevo_mazo = Enum.map(mazo, fn item ->
              if item.id == id, do: %{item | activo: true}, else: item
            end)

            {:ok, nuevo_mazo}
          end
        else
          nuevo_mazo = Enum.map(mazo, fn item ->
            if item.id == id, do: %{item | activo: false}, else: item
          end)

          {:ok, nuevo_mazo}
        end
    end
  end

  # [UPDATE] Ajusta potencia de script usando Enum.map.
  def modificar_script(mazo, id, cambio_potencia, max_ram) do
    script_existente = buscar_script_por_id(mazo, id)

    case script_existente do
      nil ->
        {:error, "Script no encontrado en la RAM"}

      s ->
        nueva_pot = s.potencia + cambio_potencia

        if nueva_pot < 0 do
          {:error, "La potencia no puede ser negativa"}
        else
          nueva_ram = calcular_ram_script(nueva_pot)
          diferencia = if s.activo, do: nueva_ram - s.ram_mb, else: 0
          ram_actual = calcular_ram_total(mazo)

          if ram_actual + diferencia > max_ram do
            {:error, "Superaria el limite de RAM (#{max_ram} MB)"}
          else
            nuevo_mazo = Enum.map(mazo, fn item ->
              if item.id == id do
                %{item | potencia: nueva_pot, ram_mb: nueva_ram}
              else
                item
              end
            end)

            {:ok, nuevo_mazo}
          end
        end
    end
  end

  # [DELETE] Borra un script usando Enum.reject.
  def purgar_script(mazo, id) do
    if buscar_script_por_id(mazo, id) == nil do
      {:error, "No existe un script con id #{id}"}
    else
      nuevo_mazo = Enum.reject(mazo, fn script -> script.id == id end)
      {:ok, nuevo_mazo}
    end
  end
end
