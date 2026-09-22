defmodule DungeonNarrativo do
  @moduledoc """
  Modulo de gestion de inventario, misiones y evaluacion de decisiones narrativas.
  """

  # [CREATE] Crea un nuevo mapa para un objeto o recompensa de historia.
  def crear_item(id, nombre, tipo, durabilidad) do
    %{
      id: id,
      nombre: nombre,
      tipo: String.downcase(tipo),
      durabilidad: durabilidad
    }
  end

  # [CREATE] Agrega un objeto a la mochila tras un evento narrativo.
  def agregar_item(inventario, nuevo_item) do
    if buscar_item_por_id(inventario, nuevo_item.id) != nil do
      {:error, "Ya tienes un objeto con la ID #{nuevo_item.id}"}
    else
      {:ok, [nuevo_item | inventario]}
    end
  end

  # [READ] Muestra todos los objetos en inventario usando Enum.each.
  def listar_items(inventario) do
    if inventario == [] do
      Util.mostrar_mensaje("Mochila vacia. No llevas objetos de mision.")
    else
      Util.mostrar_mensaje("Objetos en Mochila:")
      Enum.each(inventario, fn i ->
        Util.mostrar_mensaje("ID #{i.id} - #{i.nombre} - Tipo: #{i.tipo} - Usos/Durabilidad: #{i.durabilidad}")
      end)
    end
  end

  # [READ] Busca un objeto por su ID usando Enum.find.
  def buscar_item_por_id(inventario, id) do
    Enum.find(inventario, fn i -> i.id == id end)
  end

  # [READ] Verifica si el jugador posee un tipo de objeto usando Enum.find.
  def tiene_tipo_item?(inventario, tipo_buscado) do
    Enum.find(inventario, fn i -> i.tipo == String.downcase(tipo_buscado) end) != nil
  end

  # [READ] Filtra objetos por categoria usando Enum.filter.
  def filtrar_por_tipo(inventario, tipo_buscado) do
    Enum.filter(inventario, fn i ->
      i.tipo == String.downcase(tipo_buscado)
    end)
  end

  # Suma la durabilidad acumulada de las herramientas usando Enum.reduce.
  def calcular_durabilidad_total(inventario) do
    Enum.reduce(inventario, 0, fn item, acc ->
      item.durabilidad + acc
    end)
  end

  # [UPDATE] Modifica la durabilidad de un objeto usando Enum.map.
  def modificar_durabilidad(inventario, id, cambio_durabilidad) do
    item = buscar_item_por_id(inventario, id)

    case item do
      nil ->
        {:error, "Objeto no encontrado"}

      i ->
        nueva_dur = i.durabilidad + cambio_durabilidad

        if nueva_dur < 0 do
          {:error, "La durabilidad no puede ser negativa"}
        else
          nuevo_inv = Enum.map(inventario, fn item ->
            if item.id == id, do: %{item | durabilidad: nueva_dur}, else: item
          end)

          {:ok, nuevo_inv}
        end
    end
  end

  # [DELETE] Descarta o gasta un objeto usando Enum.reject.
  def descartar_item(inventario, id) do
    if buscar_item_por_id(inventario, id) == nil do
      {:error, "No tienes un objeto con ID #{id}"}
    else
      nuevo_inv = Enum.reject(inventario, fn i -> i.id == id end)
      {:ok, nuevo_inv}
    end
  end
end
