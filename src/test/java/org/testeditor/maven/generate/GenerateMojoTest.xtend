package org.testeditor.maven.generate

import org.apache.maven.project.MavenProject
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mock
import org.mockito.runners.MockitoJUnitRunner
import org.twdata.maven.mojoexecutor.MojoExecutor.Element

import static org.junit.Assert.*
import static org.mockito.Mockito.*

@RunWith(MockitoJUnitRunner)
class GenerateMojoTest {

	GenerateMojo mojo = new GenerateMojo
	@Mock MavenProject project

	@Before
	def void setupMojo() {
		mojo.testEditorVersion = "1.5.0"
		mojo.project = project
		mojo.testEditorOutput = "my/output/dir"
	}

	@Test
	def void emptySourceRootsWhenProjectHasNone() {
		// when
		val sourceRoots = mojo.sourceRoots

		// then
		sourceRoots.assertEquals("<sourceRoots/>")
	}

	@Test
	def void configuresSourceRoots() {
		// given
		when(project.compileSourceRoots).thenReturn(#["src/main/java", "src/main/groovy"])
		when(project.testCompileSourceRoots).thenReturn(#["src/test/java", "src/it/java"])

		// when
		val sourceRoots = mojo.sourceRoots

		// then
		sourceRoots.assertEquals('''
			<sourceRoots>
			  <sourceRoot>src/main/java</sourceRoot>
			  <sourceRoot>src/main/groovy</sourceRoot>
			  <sourceRoot>src/test/java</sourceRoot>
			  <sourceRoot>src/it/java</sourceRoot>
			</sourceRoots>
		''')
	}

	@Test
	def void languageSetupFor_1_2_0() {
		// given
		mojo.testEditorVersion = "1.2.0"

		// when
		val languages = mojo.languages

		// then
		languages.assertEquals('''
			<languages>
			  <language>
			    <setup>org.testeditor.aml.dsl.AmlStandaloneSetup</setup>
			  </language>
			  <language>
			    <setup>org.testeditor.tsl.dsl.TslStandaloneSetup</setup>
			  </language>
			  <language>
			    <setup>org.testeditor.tcl.dsl.TclStandaloneSetup</setup>
			    <outputConfigurations>
			      <outputConfiguration>
			        <outputDirectory>«mojo.testEditorOutput»</outputDirectory>
			      </outputConfiguration>
			    </outputConfigurations>
			  </language>
			</languages>
		''')
	}

	@Test
	def void dependenciesFor_1_6_0() {
		// given
		mojo.testEditorVersion = "1.6.0"

		// when
		val dependencies = mojo.dependencies

		// then
		assertNotNull(dependencies.findFirst[artifactId == 'gson'])
	}

	@Test
	def void dependenciesFor_1_2_0() {
		// given
		mojo.testEditorVersion = "1.2.0"

		// when
		val dependencies = mojo.dependencies

		// then
		assertNotNull(dependencies.findFirst[artifactId == 'org.testeditor.dsl.common.model'])
	}

	@Test
	def void xtextVersionIsDerivedFor_1_5_0() {
		// given
		mojo.testEditorVersion = "1.5.0"
		mojo.xtextVersion = null

		// when
		mojo.configureXtextVersion

		// then
		assertEquals("2.10.0", mojo.xtextVersion)
	}

	@Test
	def void xtextVersionIsDerivedFor_1_6_0() {
		// given
		mojo.testEditorVersion = "1.6.0"
		mojo.xtextVersion = null

		// when
		mojo.configureXtextVersion

		// then
		assertEquals("2.11.0", mojo.xtextVersion)
	}

	@Test
	def void xtextVersionIsNotOverwrittenIfSet() {
		// given
		mojo.testEditorVersion = "1.5.0"
		mojo.xtextVersion = "custom"

		// when
		mojo.configureXtextVersion

		// then
		assertEquals("custom", mojo.xtextVersion)
	}

	private def void assertEquals(Element actual, CharSequence expected) {
		val fullXml = actual.toDom.toString
		val xml = fullXml.substring(fullXml.indexOf('\n') + 1) // remove header
		Assert.assertEquals(expected.toString.trim, xml)
	}

}
