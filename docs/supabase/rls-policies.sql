-- Políticas RLS recomendadas para el proyecto
-- ============================================================
-- Ejecuta este archivo en el SQL Editor de Supabase después de
-- haber creado el schema base y las extensiones.
--
-- Roles reconocidos por la aplicación:
--   1 = Administrador
--   2 = Secretaria
--   3 = Médico
--   4 = Paciente
-- ============================================================

-- ------------------------------------------------------------
-- Helpers reutilizables
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.current_user_rol()
RETURNS INTEGER AS $$
  SELECT id_rol FROM public.usuario WHERE id_usuario = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ------------------------------------------------------------
-- 1. Tabla public.usuario
-- ------------------------------------------------------------
ALTER TABLE public.usuario ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Usuarios autenticados pueden ver usuarios" ON public.usuario;
CREATE POLICY "Usuarios autenticados pueden ver usuarios"
  ON public.usuario FOR SELECT
  USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Usuarios pueden editar su propio perfil" ON public.usuario;
CREATE POLICY "Usuarios pueden editar su propio perfil"
  ON public.usuario FOR UPDATE
  USING (id_usuario = auth.uid());

-- ------------------------------------------------------------
-- 2. Tabla public.cita
-- ------------------------------------------------------------
ALTER TABLE public.cita ENABLE ROW LEVEL SECURITY;

-- SELECT
DROP POLICY IF EXISTS "Admins y secretarias ven todas las citas" ON public.cita;
CREATE POLICY "Admins y secretarias ven todas las citas"
  ON public.cita FOR SELECT
  USING (public.current_user_rol() IN (1, 2));

DROP POLICY IF EXISTS "Medicos ven sus citas asignadas" ON public.cita;
CREATE POLICY "Medicos ven sus citas asignadas"
  ON public.cita FOR SELECT
  USING (public.current_user_rol() = 3 AND id_medico = auth.uid());

DROP POLICY IF EXISTS "Pacientes ven sus propias citas" ON public.cita;
CREATE POLICY "Pacientes ven sus propias citas"
  ON public.cita FOR SELECT
  USING (public.current_user_rol() = 4 AND id_paciente = auth.uid());

-- INSERT
DROP POLICY IF EXISTS "Admins y secretarias pueden crear citas" ON public.cita;
CREATE POLICY "Admins y secretarias pueden crear citas"
  ON public.cita FOR INSERT
  WITH CHECK (public.current_user_rol() IN (1, 2));

DROP POLICY IF EXISTS "Pacientes pueden crear sus propias citas" ON public.cita;
CREATE POLICY "Pacientes pueden crear sus propias citas"
  ON public.cita FOR INSERT
  WITH CHECK (public.current_user_rol() = 4 AND id_paciente = auth.uid());

-- UPDATE
DROP POLICY IF EXISTS "Admins y secretarias pueden actualizar cualquier cita" ON public.cita;
CREATE POLICY "Admins y secretarias pueden actualizar cualquier cita"
  ON public.cita FOR UPDATE
  USING (public.current_user_rol() IN (1, 2));

DROP POLICY IF EXISTS "Medicos pueden actualizar sus citas asignadas" ON public.cita;
CREATE POLICY "Medicos pueden actualizar sus citas asignadas"
  ON public.cita FOR UPDATE
  USING (public.current_user_rol() = 3 AND id_medico = auth.uid());

DROP POLICY IF EXISTS "Pacientes pueden cancelar sus citas solicitadas" ON public.cita;
CREATE POLICY "Pacientes pueden cancelar sus citas solicitadas"
  ON public.cita FOR UPDATE
  USING (
    public.current_user_rol() = 4
    AND id_paciente = auth.uid()
    AND estado = 'solicitado'
  );

-- DELETE
DROP POLICY IF EXISTS "Admins pueden eliminar citas" ON public.cita;
CREATE POLICY "Admins pueden eliminar citas"
  ON public.cita FOR DELETE
  USING (public.current_user_rol() = 1);

-- ------------------------------------------------------------
-- 3. Tabla public.horario_medico
-- ------------------------------------------------------------
ALTER TABLE public.horario_medico ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Cualquier usuario autenticado puede ver horarios" ON public.horario_medico;
CREATE POLICY "Cualquier usuario autenticado puede ver horarios"
  ON public.horario_medico FOR SELECT
  USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Medicos gestionan sus propios horarios" ON public.horario_medico;
CREATE POLICY "Medicos gestionan sus propios horarios"
  ON public.horario_medico FOR ALL
  USING (id_medico = auth.uid())
  WITH CHECK (id_medico = auth.uid());

DROP POLICY IF EXISTS "Admins y secretarias gestionan horarios" ON public.horario_medico;
CREATE POLICY "Admins y secretarias gestionan horarios"
  ON public.horario_medico FOR ALL
  USING (public.current_user_rol() IN (1, 2))
  WITH CHECK (public.current_user_rol() IN (1, 2));

-- ------------------------------------------------------------
-- 4. Tabla public.historial_clinico
-- ------------------------------------------------------------
ALTER TABLE public.historial_clinico ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Medicos ven y gestionan historiales de sus citas" ON public.historial_clinico;
CREATE POLICY "Medicos ven y gestionan historiales de sus citas"
  ON public.historial_clinico FOR ALL
  USING (
    public.current_user_rol() = 3
    AND EXISTS (
      SELECT 1 FROM public.cita c
      WHERE c.id_cita = historial_clinico.id_cita
        AND c.id_medico = auth.uid()
    )
  )
  WITH CHECK (
    public.current_user_rol() = 3
    AND EXISTS (
      SELECT 1 FROM public.cita c
      WHERE c.id_cita = historial_clinico.id_cita
        AND c.id_medico = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Pacientes ven sus propios historiales" ON public.historial_clinico;
CREATE POLICY "Pacientes ven sus propios historiales"
  ON public.historial_clinico FOR SELECT
  USING (
    public.current_user_rol() = 4
    AND EXISTS (
      SELECT 1 FROM public.cita c
      WHERE c.id_cita = historial_clinico.id_cita
        AND c.id_paciente = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins y secretarias ven historiales" ON public.historial_clinico;
CREATE POLICY "Admins y secretarias ven historiales"
  ON public.historial_clinico FOR SELECT
  USING (public.current_user_rol() IN (1, 2));

-- ------------------------------------------------------------
-- 5. Tabla public.historial_cita (log de cambios de estado)
-- ------------------------------------------------------------
ALTER TABLE public.historial_cita ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins y secretarias ven historial de cambios" ON public.historial_cita;
CREATE POLICY "Admins y secretarias ven historial de cambios"
  ON public.historial_cita FOR SELECT
  USING (public.current_user_rol() IN (1, 2));

DROP POLICY IF EXISTS "Medicos ven historial de sus citas" ON public.historial_cita;
CREATE POLICY "Medicos ven historial de sus citas"
  ON public.historial_cita FOR SELECT
  USING (
    public.current_user_rol() = 3
    AND EXISTS (
      SELECT 1 FROM public.cita c
      WHERE c.id_cita = historial_cita.id_cita
        AND c.id_medico = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Pacientes ven historial de sus citas" ON public.historial_cita;
CREATE POLICY "Pacientes ven historial de sus citas"
  ON public.historial_cita FOR SELECT
  USING (
    public.current_user_rol() = 4
    AND EXISTS (
      SELECT 1 FROM public.cita c
      WHERE c.id_cita = historial_cita.id_cita
        AND c.id_paciente = auth.uid()
    )
  );
